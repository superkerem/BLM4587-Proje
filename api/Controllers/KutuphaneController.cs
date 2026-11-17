using System.Data;
using System.Globalization;
using api.Data;
using api.Dtos;
using api.Models;
using api.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.JsonWebTokens;
using Npgsql;

namespace api.Controllers
{
    [ApiController]
    [Route("api/kutuphane")]
    [Authorize]
    public class KutuphaneController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public KutuphaneController(ApplicationDbContext context)
        {
            _context = context;
        }

        [HttpGet("masalar")]
        [ProducesResponseType<List<MasaDurumu>>(StatusCodes.Status200OK)]
        [ProducesResponseType<HataYaniti>(StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> Masalar([FromQuery] string? tarih, [FromQuery] string? baslangic, [FromQuery] int? sure)
        {
            var simdi = DateTime.UtcNow;
            DateTime araligBasi, araligSonu;

            if (tarih == null && baslangic == null && sure == null)
            {
                araligBasi = simdi;
                araligSonu = simdi.AddSeconds(1);
            }
            else
            {
                if (!TarihCoz(tarih, out var gun) || !SaatCoz(baslangic, out var saat) || sure == null)
                {
                    return BadRequest(new HataYaniti("Tarih (YYYY-AA-GG), başlangıç (SS:dd) ve süre birlikte gönderilmelidir."));
                }

                if (KutuphaneKurallari.Denetle(gun, saat, sure.Value, simdi) is { } hata)
                {
                    return BadRequest(HataYaniti.Alan(hata.Alan, hata.Mesaj));
                }

                araligBasi = KutuphaneKurallari.Utc(gun, KutuphaneKurallari.Dakika(saat));
                araligSonu = araligBasi.AddMinutes(sure.Value);
            }

            var dolular = await DoluMasalarAsync(araligBasi, araligSonu);
            var masalar = await _context.KutuphaneMasalari
                .AsNoTracking()
                .OrderBy(m => m.Kat)
                .ThenBy(m => m.MasaNo)
                .ToListAsync();

            return Ok(masalar.Select(m => new MasaDurumu(m.Id, m.MasaNo, m.Kat, m.Kapasite, m.PrizVarMi, !dolular.Contains(m.Id))));
        }

        [HttpGet("doluluk")]
        [ProducesResponseType<DolulukBilgisi>(StatusCodes.Status200OK)]
        public async Task<IActionResult> Doluluk()
        {
            var simdi = DateTime.UtcNow;
            var acikMi = KutuphaneKurallari.AcikMi(simdi);
            var dolular = acikMi ? await DoluMasalarAsync(simdi, simdi.AddSeconds(1)) : new HashSet<int>();

            var masalar = await _context.KutuphaneMasalari
                .AsNoTracking()
                .Select(m => new { m.Id, m.Kat })
                .ToListAsync();

            var katlar = masalar
                .GroupBy(m => m.Kat)
                .OrderBy(g => g.Key)
                .Select(g => new KatDolulugu(g.Key, g.Count(), g.Count(m => dolular.Contains(m.Id))))
                .ToList();

            var toplam = masalar.Count;
            var dolu = masalar.Count(m => dolular.Contains(m.Id));
            var oran = toplam == 0 ? 0 : (int)Math.Round(dolu * 100.0 / toplam);

            return Ok(new DolulukBilgisi(
                KutuphaneKurallari.TurkiyeSaati(simdi).ToString("HH:mm", CultureInfo.InvariantCulture),
                acikMi,
                toplam,
                dolu,
                oran,
                katlar));
        }

        [HttpGet("rezervasyonlarim")]
        [ProducesResponseType<List<RezervasyonBilgisi>>(StatusCodes.Status200OK)]
        [ProducesResponseType<HataYaniti>(StatusCodes.Status401Unauthorized)]
        public async Task<IActionResult> Rezervasyonlarim()
        {
            if (KullaniciId() is not int kullaniciId)
            {
                return Unauthorized(new HataYaniti("Bu işlem için giriş yapmalısınız."));
            }

            var simdi = DateTime.UtcNow;
            var (bugunBasi, _) = KutuphaneKurallari.GunAraligiUtc(DateOnly.FromDateTime(KutuphaneKurallari.TurkiyeSaati(simdi)));

            var rezervasyonlar = await _context.KutuphaneRezervasyonlari
                .AsNoTracking()
                .Include(r => r.Masa)
                .Where(r => r.KullaniciId == kullaniciId && !r.IptalEdildiMi && r.Bitis > bugunBasi)
                .OrderBy(r => r.Baslangic)
                .ToListAsync();

            return Ok(rezervasyonlar.Select(r => Donustur(r, simdi)));
        }

        [HttpPost("rezervasyonlar")]
        [ProducesResponseType<RezervasyonBilgisi>(StatusCodes.Status201Created)]
        [ProducesResponseType<HataYaniti>(StatusCodes.Status400BadRequest)]
        [ProducesResponseType<HataYaniti>(StatusCodes.Status409Conflict)]
        public async Task<IActionResult> RezervasyonYap(RezervasyonIstegi istek)
        {
            if (KullaniciId() is not int kullaniciId)
            {
                return Unauthorized(new HataYaniti("Bu işlem için giriş yapmalısınız."));
            }

            if (!TarihCoz(istek.Tarih, out var tarih))
            {
                return BadRequest(HataYaniti.Alan("tarih", "Geçerli bir tarih giriniz."));
            }

            if (!SaatCoz(istek.Baslangic, out var baslangic))
            {
                return BadRequest(HataYaniti.Alan("baslangic", "Geçerli bir başlangıç saati giriniz."));
            }

            var simdi = DateTime.UtcNow;
            if (KutuphaneKurallari.Denetle(tarih, baslangic, istek.SureDakika, simdi) is { } hata)
            {
                return BadRequest(HataYaniti.Alan(hata.Alan, hata.Mesaj));
            }

            var masa = await _context.KutuphaneMasalari.FindAsync(istek.MasaId);
            if (masa == null)
            {
                return BadRequest(HataYaniti.Alan("masaId", "Seçilen masa bulunamadı."));
            }

            var yeniBaslangic = KutuphaneKurallari.Utc(tarih, KutuphaneKurallari.Dakika(baslangic));
            var yeniBitis = yeniBaslangic.AddMinutes(istek.SureDakika);
            var (gunBasi, gunSonu) = KutuphaneKurallari.GunAraligiUtc(tarih);

            try
            {
                await using var islem = await _context.Database.BeginTransactionAsync(IsolationLevel.Serializable);

                var masaDolu = await _context.KutuphaneRezervasyonlari.AnyAsync(r =>
                    r.MasaId == masa.Id && r.Baslangic < yeniBitis && r.Bitis > yeniBaslangic && !r.IptalEdildiMi);
                if (masaDolu)
                {
                    return Conflict(new HataYaniti("Bu masa seçtiğiniz saatlerde dolu. Başka bir masa ya da saat seçin."));
                }

                var kisiDolu = await _context.KutuphaneRezervasyonlari.AnyAsync(r =>
                    r.KullaniciId == kullaniciId && r.Baslangic < yeniBitis && r.Bitis > yeniBaslangic && !r.IptalEdildiMi);
                if (kisiDolu)
                {
                    return BadRequest(HataYaniti.Alan("baslangic", "Bu saatlerde başka bir masada rezervasyonunuz var."));
                }

                var gunlukler = await _context.KutuphaneRezervasyonlari
                    .Where(r => r.KullaniciId == kullaniciId && !r.IptalEdildiMi && r.Baslangic >= gunBasi && r.Baslangic < gunSonu)
                    .Select(r => new { r.Baslangic, r.Bitis })
                    .ToListAsync();

                var kullanilan = gunlukler.Sum(r => (int)(r.Bitis - r.Baslangic).TotalMinutes);
                if (kullanilan + istek.SureDakika > KutuphaneKurallari.GunlukToplamDakika)
                {
                    var kalan = Math.Max(0, KutuphaneKurallari.GunlukToplamDakika - kullanilan);
                    return BadRequest(HataYaniti.Alan("sureDakika",
                        $"Bir günde toplam en fazla 5 saat rezervasyon yapılabilir. Bu gün için kalan süreniz {kalan} dakika."));
                }

                var rezervasyon = new KutuphaneRezervasyonu
                {
                    MasaId = masa.Id,
                    KullaniciId = kullaniciId,
                    Baslangic = yeniBaslangic,
                    Bitis = yeniBitis,
                    OlusturmaTarihi = simdi
                };

                _context.KutuphaneRezervasyonlari.Add(rezervasyon);
                await _context.SaveChangesAsync();
                await islem.CommitAsync();

                rezervasyon.Masa = masa;
                return StatusCode(StatusCodes.Status201Created, Donustur(rezervasyon, simdi));
            }
            catch (Exception istisna) when (SerilestirmeHatasiMi(istisna))
            {
                return Conflict(new HataYaniti("Bu masa az önce başka biri tarafından ayrıldı. Lütfen tekrar deneyin."));
            }
        }

        [HttpDelete("rezervasyonlar/{id:int}")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType<HataYaniti>(StatusCodes.Status400BadRequest)]
        [ProducesResponseType<HataYaniti>(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> IptalEt(int id)
        {
            var rezervasyon = await KendiRezervasyonuAsync(id);
            if (rezervasyon == null)
            {
                return NotFound(new HataYaniti("Rezervasyon bulunamadı."));
            }

            if (rezervasyon.Baslangic <= DateTime.UtcNow)
            {
                return BadRequest(new HataYaniti("Başlamış bir rezervasyon iptal edilemez; masayı boşaltabilirsiniz."));
            }

            rezervasyon.IptalEdildiMi = true;
            await _context.SaveChangesAsync();
            return NoContent();
        }

        [HttpPost("rezervasyonlar/{id:int}/bosalt")]
        [ProducesResponseType<RezervasyonBilgisi>(StatusCodes.Status200OK)]
        [ProducesResponseType<HataYaniti>(StatusCodes.Status400BadRequest)]
        [ProducesResponseType<HataYaniti>(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> Bosalt(int id)
        {
            var rezervasyon = await KendiRezervasyonuAsync(id);
            if (rezervasyon == null)
            {
                return NotFound(new HataYaniti("Rezervasyon bulunamadı."));
            }

            var simdi = DateTime.UtcNow;
            if (rezervasyon.Baslangic > simdi || rezervasyon.Bitis <= simdi)
            {
                return BadRequest(new HataYaniti("Sadece devam eden bir rezervasyonun masası boşaltılabilir."));
            }

            rezervasyon.Bitis = simdi;
            rezervasyon.BosaltildiMi = true;
            await _context.SaveChangesAsync();

            return Ok(Donustur(rezervasyon, simdi));
        }

        private async Task<HashSet<int>> DoluMasalarAsync(DateTime baslangic, DateTime bitis)
        {
            var idler = await _context.KutuphaneRezervasyonlari
                .Where(r => r.Baslangic < bitis && r.Bitis > baslangic && !r.IptalEdildiMi)
                .Select(r => r.MasaId)
                .Distinct()
                .ToListAsync();
            return idler.ToHashSet();
        }

        private async Task<KutuphaneRezervasyonu?> KendiRezervasyonuAsync(int id)
        {
            if (KullaniciId() is not int kullaniciId) return null;

            return await _context.KutuphaneRezervasyonlari
                .Include(r => r.Masa)
                .FirstOrDefaultAsync(r => r.Id == id && r.KullaniciId == kullaniciId && !r.IptalEdildiMi);
        }

        private int? KullaniciId() =>
            int.TryParse(User.FindFirst(JwtRegisteredClaimNames.Sub)?.Value, out var id) ? id : null;

        private static bool TarihCoz(string? metin, out DateOnly tarih) =>
            DateOnly.TryParseExact(metin, "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out tarih);

        private static bool SaatCoz(string? metin, out TimeOnly saat) =>
            TimeOnly.TryParseExact(metin, "HH:mm", CultureInfo.InvariantCulture, DateTimeStyles.None, out saat);

        private static bool SerilestirmeHatasiMi(Exception hata)
        {
            for (Exception? e = hata; e != null; e = e.InnerException)
            {
                if (e is PostgresException { SqlState: PostgresErrorCodes.SerializationFailure }) return true;
            }
            return false;
        }

        private static RezervasyonBilgisi Donustur(KutuphaneRezervasyonu r, DateTime simdi)
        {
            var baslangic = KutuphaneKurallari.TurkiyeSaati(r.Baslangic);
            var bitis = KutuphaneKurallari.TurkiyeSaati(r.Bitis);

            var durum = r.BosaltildiMi || r.Bitis <= simdi
                ? "Tamamlandi"
                : r.Baslangic <= simdi ? "DevamEdiyor" : "Yaklasan";

            return new RezervasyonBilgisi(
                r.Id,
                r.MasaId,
                r.Masa?.MasaNo ?? string.Empty,
                r.Masa?.Kat ?? 0,
                baslangic.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture),
                baslangic.ToString("HH:mm", CultureInfo.InvariantCulture),
                bitis.ToString("HH:mm", CultureInfo.InvariantCulture),
                durum);
        }
    }
}
