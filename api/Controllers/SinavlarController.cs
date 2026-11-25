using System.Globalization;
using api.Data;
using api.Dtos;
using api.Models;
using api.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace api.Controllers
{
    [ApiController]
    [Authorize]
    public class SinavlarController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public SinavlarController(ApplicationDbContext context)
        {
            _context = context;
        }

        [HttpGet("api/sinavlar")]
        [ProducesResponseType<List<SinavGrubuBilgisi>>(StatusCodes.Status200OK)]
        public async Task<IActionResult> DersSinavlari([FromQuery] string? dersKodlari)
        {
            var kodlar = (dersKodlari ?? string.Empty)
                .Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries)
                .Select(k => k.ToUpperInvariant())
                .Distinct()
                .ToList();

            if (kodlar.Count == 0)
            {
                return Ok(new List<SinavGrubuBilgisi>());
            }

            var gruplar = await GruplariGetirAsync(s => kodlar.Contains(s.DersKodu));
            var yaklasanlar = gruplar.Where(g => !g.TamamlandiMi);
            var gecmisler = gruplar.Where(g => g.TamamlandiMi).Reverse();

            return Ok(yaklasanlar.Concat(gecmisler).ToList());
        }

        [HttpGet("api/yonetim/sinavlar")]
        [Authorize(Policy = Politikalar.SadeceYonetici)]
        [ProducesResponseType<YonetimSinavlariYaniti>(StatusCodes.Status200OK)]
        [ProducesResponseType<HataYaniti>(StatusCodes.Status403Forbidden)]
        public async Task<IActionResult> YonetimListesi()
        {
            var gruplar = await GruplariGetirAsync(_ => true);

            return Ok(new YonetimSinavlariYaniti(
                gruplar.Where(g => !g.TamamlandiMi).ToList(),
                gruplar.Where(g => g.TamamlandiMi).Reverse().ToList()));
        }

        [HttpGet("api/yonetim/sinavlar/{id:int}")]
        [Authorize(Policy = Politikalar.SadeceYonetici)]
        [ProducesResponseType<SinavDetayi>(StatusCodes.Status200OK)]
        [ProducesResponseType<HataYaniti>(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> Getir(int id)
        {
            var grup = await GrubuBulAsync(id);
            if (grup.Count == 0)
            {
                return NotFound(new HataYaniti("Sınav bulunamadı."));
            }

            var sinav = grup[0];
            return Ok(new SinavDetayi(
                sinav.Id,
                sinav.DersKodu,
                sinav.Tur.ToString(),
                sinav.Tarih.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture),
                sinav.BaslangicSaati.ToString("HH:mm", CultureInfo.InvariantCulture),
                sinav.BitisSaati.ToString("HH:mm", CultureInfo.InvariantCulture),
                grup.Where(s => s.DerslikId != null).Select(s => s.DerslikId!.Value).Distinct().ToList()));
        }

        [HttpPost("api/yonetim/sinavlar")]
        [Authorize(Policy = Politikalar.SadeceYonetici)]
        [ProducesResponseType<SinavDetayi>(StatusCodes.Status201Created)]
        [ProducesResponseType<HataYaniti>(StatusCodes.Status400BadRequest)]
        [ProducesResponseType<HataYaniti>(StatusCodes.Status403Forbidden)]
        public async Task<IActionResult> Ekle(SinavIstegi istek)
        {
            var hata = await IstegiDenetleAsync(istek);
            if (hata != null)
            {
                return BadRequest(hata);
            }

            var kayitlar = KayitlariOlustur(istek);
            _context.Sinavlar.AddRange(kayitlar);
            await _context.SaveChangesAsync();

            return StatusCode(StatusCodes.Status201Created, Detay(kayitlar));
        }

        [HttpPut("api/yonetim/sinavlar/{id:int}")]
        [Authorize(Policy = Politikalar.SadeceYonetici)]
        [ProducesResponseType<SinavDetayi>(StatusCodes.Status200OK)]
        [ProducesResponseType<HataYaniti>(StatusCodes.Status400BadRequest)]
        [ProducesResponseType<HataYaniti>(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> Guncelle(int id, SinavIstegi istek)
        {
            var eskiGrup = await GrubuBulAsync(id);
            if (eskiGrup.Count == 0)
            {
                return NotFound(new HataYaniti("Sınav bulunamadı."));
            }

            var hata = await IstegiDenetleAsync(istek);
            if (hata != null)
            {
                return BadRequest(hata);
            }

            _context.Sinavlar.RemoveRange(eskiGrup);
            var kayitlar = KayitlariOlustur(istek);
            _context.Sinavlar.AddRange(kayitlar);
            await _context.SaveChangesAsync();

            return Ok(Detay(kayitlar));
        }

        [HttpDelete("api/yonetim/sinavlar/{id:int}")]
        [Authorize(Policy = Politikalar.SadeceYonetici)]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType<HataYaniti>(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> Sil(int id)
        {
            var grup = await GrubuBulAsync(id);
            if (grup.Count == 0)
            {
                return NotFound(new HataYaniti("Sınav bulunamadı."));
            }

            _context.Sinavlar.RemoveRange(grup);
            await _context.SaveChangesAsync();
            return NoContent();
        }

        private async Task<List<SinavGrubuBilgisi>> GruplariGetirAsync(System.Linq.Expressions.Expression<Func<Sinav, bool>> filtre)
        {
            var bugun = DateOnly.FromDateTime(KutuphaneKurallari.TurkiyeSaati(DateTime.UtcNow));

            var sinavlar = await _context.Sinavlar
                .AsNoTracking()
                .Include(s => s.Derslik)
                .ThenInclude(d => d!.Mekan)
                .Where(filtre)
                .ToListAsync();

            var dersAdlari = await DersAdlariAsync();

            return sinavlar
                .GroupBy(s => new { s.DersKodu, s.Tur, s.Tarih, s.BaslangicSaati, s.BitisSaati })
                .Select(g =>
                {
                    var ilk = g.OrderBy(s => s.Id).First();
                    return new SinavGrubuBilgisi(
                        ilk.Id,
                        ilk.DersKodu,
                        dersAdlari.GetValueOrDefault(ilk.DersKodu, ilk.DersKodu),
                        ilk.Tur.ToString(),
                        ilk.Tarih.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture),
                        ilk.BaslangicSaati.ToString("HH:mm", CultureInfo.InvariantCulture),
                        ilk.BitisSaati.ToString("HH:mm", CultureInfo.InvariantCulture),
                        g.Where(s => s.Derslik != null)
                            .Select(s => s.Derslik!)
                            .DistinctBy(d => d.Id)
                            .OrderBy(d => d.Ad)
                            .Select(d => new SinavDersligi(d.Id, d.Ad, d.MekanId, d.Mekan?.Ad))
                            .ToList(),
                        ilk.Tarih < bugun);
                })
                .OrderBy(g => g.Tarih)
                .ThenBy(g => g.Baslangic)
                .ToList();
        }

        private async Task<Dictionary<string, string>> DersAdlariAsync()
        {
            var dersler = await _context.Dersler
                .AsNoTracking()
                .OrderBy(d => d.LabMi)
                .ThenBy(d => d.Id)
                .Select(d => new { d.Kod, d.DersAdi })
                .ToListAsync();

            return dersler
                .GroupBy(d => d.Kod)
                .ToDictionary(g => g.Key, g => g.First().DersAdi);
        }

        private async Task<List<Sinav>> GrubuBulAsync(int id)
        {
            var sinav = await _context.Sinavlar.AsNoTracking().FirstOrDefaultAsync(s => s.Id == id);
            if (sinav == null)
            {
                return new List<Sinav>();
            }

            return await _context.Sinavlar
                .Where(s => s.DersKodu == sinav.DersKodu && s.Tur == sinav.Tur && s.Tarih == sinav.Tarih &&
                    s.BaslangicSaati == sinav.BaslangicSaati && s.BitisSaati == sinav.BitisSaati)
                .OrderBy(s => s.Id)
                .ToListAsync();
        }

        private async Task<HataYaniti?> IstegiDenetleAsync(SinavIstegi istek)
        {
            var hatalar = new Dictionary<string, string[]>();

            if (!await _context.Dersler.AnyAsync(d => d.Kod == istek.DersKodu))
            {
                hatalar["dersKodu"] = new[] { "Ders programında böyle bir ders yok." };
            }

            var derslikIdleri = istek.DerslikIdleri.Distinct().ToList();
            var bulunan = await _context.Derslikler.CountAsync(d => derslikIdleri.Contains(d.Id));
            if (bulunan != derslikIdleri.Count)
            {
                hatalar["derslikIdleri"] = new[] { "Seçilen dersliklerden biri bulunamadı." };
            }

            return hatalar.Count == 0 ? null : new HataYaniti("Gönderilen bilgiler geçersiz.", hatalar);
        }

        private static List<Sinav> KayitlariOlustur(SinavIstegi istek)
        {
            var tur = Enum.Parse<SinavTuru>(istek.Tur);
            var tarih = DateOnly.ParseExact(istek.Tarih, "yyyy-MM-dd", CultureInfo.InvariantCulture);
            var baslangic = TimeOnly.ParseExact(istek.Baslangic, "HH:mm", CultureInfo.InvariantCulture);
            var bitis = TimeOnly.ParseExact(istek.Bitis, "HH:mm", CultureInfo.InvariantCulture);

            return istek.DerslikIdleri
                .Distinct()
                .Select(derslikId => new Sinav
                {
                    DersKodu = istek.DersKodu,
                    Tur = tur,
                    Tarih = tarih,
                    BaslangicSaati = baslangic,
                    BitisSaati = bitis,
                    DerslikId = derslikId
                })
                .ToList();
        }

        private static SinavDetayi Detay(List<Sinav> kayitlar)
        {
            var ilk = kayitlar.OrderBy(s => s.Id).First();
            return new SinavDetayi(
                ilk.Id,
                ilk.DersKodu,
                ilk.Tur.ToString(),
                ilk.Tarih.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture),
                ilk.BaslangicSaati.ToString("HH:mm", CultureInfo.InvariantCulture),
                ilk.BitisSaati.ToString("HH:mm", CultureInfo.InvariantCulture),
                kayitlar.Select(s => s.DerslikId!.Value).ToList());
        }
    }
}
