using api.Data;
using api.Dtos;
using api.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.JsonWebTokens;

namespace api.Controllers
{
    [ApiController]
    [Route("api/kayip-esyalar")]
    [Authorize]
    public class KayipEsyalarController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public KayipEsyalarController(ApplicationDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        [ProducesResponseType<List<KayipEsyaBilgisi>>(StatusCodes.Status200OK)]
        public async Task<IActionResult> Listele([FromQuery] bool teslimEdilmemis = false)
        {
            var sorgu = _context.KayipEsyalar.Include(e => e.BildirenKullanici).AsQueryable();

            if (teslimEdilmemis)
            {
                sorgu = sorgu.Where(e => !e.TeslimEdildiMi);
            }

            var esyalar = await sorgu
                .OrderByDescending(e => e.BulunmaTarihi)
                .ThenByDescending(e => e.Id)
                .ToListAsync();

            return Ok(esyalar.Select(Donustur));
        }

        [HttpGet("{id:int}")]
        [ProducesResponseType<KayipEsyaBilgisi>(StatusCodes.Status200OK)]
        [ProducesResponseType<HataYaniti>(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> Getir(int id)
        {
            var esya = await _context.KayipEsyalar.Include(e => e.BildirenKullanici).FirstOrDefaultAsync(e => e.Id == id);
            return esya == null ? NotFound(new HataYaniti("İlan bulunamadı.")) : Ok(Donustur(esya));
        }

        [HttpPost]
        [ProducesResponseType<KayipEsyaBilgisi>(StatusCodes.Status201Created)]
        [ProducesResponseType<HataYaniti>(StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> Ekle(KayipEsyaIstegi istek)
        {
            // Bildiren kişi istekten değil, token'daki sub claim'inden alınır.
            if (!int.TryParse(User.FindFirst(JwtRegisteredClaimNames.Sub)?.Value, out var kullaniciId))
            {
                return Unauthorized(new HataYaniti("Bu işlem için giriş yapmalısınız."));
            }

            var tarih = UtcTarih(istek.BulunmaTarihi!.Value);
            if (tarih > DateTime.UtcNow)
            {
                return BadRequest(HataYaniti.Alan("bulunmaTarihi", "Bulunma tarihi ileri bir tarih olamaz."));
            }

            var esya = new KayipEsya
            {
                Baslik = istek.Baslik.Trim(),
                Aciklama = istek.Aciklama.Trim(),
                BulunanYer = istek.BulunanYer.Trim(),
                BulunmaTarihi = tarih,
                TeslimEdildiMi = istek.TeslimEdildiMi,
                BildirenKullaniciId = kullaniciId
            };

            _context.KayipEsyalar.Add(esya);
            await _context.SaveChangesAsync();
            await _context.Entry(esya).Reference(e => e.BildirenKullanici).LoadAsync();

            return CreatedAtAction(nameof(Getir), new { id = esya.Id }, Donustur(esya));
        }

        [HttpPut("{id:int}")]
        [ProducesResponseType<KayipEsyaBilgisi>(StatusCodes.Status200OK)]
        [ProducesResponseType<HataYaniti>(StatusCodes.Status400BadRequest)]
        [ProducesResponseType<HataYaniti>(StatusCodes.Status403Forbidden)]
        [ProducesResponseType<HataYaniti>(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> Guncelle(int id, KayipEsyaIstegi istek)
        {
            var esya = await _context.KayipEsyalar.Include(e => e.BildirenKullanici).FirstOrDefaultAsync(e => e.Id == id);
            if (esya == null)
            {
                return NotFound(new HataYaniti("İlan bulunamadı."));
            }

            if (!DuzenleyebilirMi(esya))
            {
                return YetkiYok();
            }

            var tarih = UtcTarih(istek.BulunmaTarihi!.Value);
            if (tarih > DateTime.UtcNow)
            {
                return BadRequest(HataYaniti.Alan("bulunmaTarihi", "Bulunma tarihi ileri bir tarih olamaz."));
            }

            esya.Baslik = istek.Baslik.Trim();
            esya.Aciklama = istek.Aciklama.Trim();
            esya.BulunanYer = istek.BulunanYer.Trim();
            esya.BulunmaTarihi = tarih;
            esya.TeslimEdildiMi = istek.TeslimEdildiMi;
            await _context.SaveChangesAsync();

            return Ok(Donustur(esya));
        }

        [HttpDelete("{id:int}")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType<HataYaniti>(StatusCodes.Status403Forbidden)]
        [ProducesResponseType<HataYaniti>(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> Sil(int id)
        {
            var esya = await _context.KayipEsyalar.FindAsync(id);
            if (esya == null)
            {
                return NotFound(new HataYaniti("İlan bulunamadı."));
            }

            if (!DuzenleyebilirMi(esya))
            {
                return YetkiYok();
            }

            _context.KayipEsyalar.Remove(esya);
            await _context.SaveChangesAsync();
            return NoContent();
        }

        // İlanı sadece ekleyen kişi ya da Yönetici değiştirebilir.
        private bool DuzenleyebilirMi(KayipEsya esya)
        {
            var sahibiMi = int.TryParse(User.FindFirst(JwtRegisteredClaimNames.Sub)?.Value, out var kullaniciId)
                && esya.BildirenKullaniciId == kullaniciId;

            return sahibiMi || User.IsInRole(Roller.Yonetici);
        }

        private ObjectResult YetkiYok() =>
            StatusCode(StatusCodes.Status403Forbidden, new HataYaniti("Bu ilanı sadece ekleyen kişi ya da yönetici değiştirebilir."));

        // PostgreSQL timestamptz sütunu sadece UTC kabul eder; "2026-11-05" gibi saatsiz tarihler UTC sayılır.
        private static DateTime UtcTarih(DateTime tarih) => tarih.Kind switch
        {
            DateTimeKind.Utc => tarih,
            DateTimeKind.Local => tarih.ToUniversalTime(),
            _ => DateTime.SpecifyKind(tarih, DateTimeKind.Utc)
        };

        private static KayipEsyaBilgisi Donustur(KayipEsya e) => new(
            e.Id,
            e.Baslik,
            e.Aciklama,
            e.BulunanYer,
            e.BulunmaTarihi,
            e.TeslimEdildiMi,
            e.BildirenKullaniciId,
            e.BildirenKullanici != null ? $"{e.BildirenKullanici.Ad} {e.BildirenKullanici.Soyad}" : "Bilinmiyor");
    }
}
