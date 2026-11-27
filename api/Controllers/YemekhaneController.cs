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
    [Route("api/yemekhane")]
    [Authorize]
    public class YemekhaneController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public YemekhaneController(ApplicationDbContext context)
        {
            _context = context;
        }

        // ?tarih=2026-11-27 verilmezse bugünün (Türkiye saatiyle) menüsü döner.
        [HttpGet("menu")]
        [ProducesResponseType<YemekMenusuBilgisi>(StatusCodes.Status200OK)]
        [ProducesResponseType<HataYaniti>(StatusCodes.Status400BadRequest)]
        [ProducesResponseType<HataYaniti>(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> Menu([FromQuery] string? tarih)
        {
            if (!TarihiCoz(tarih, out var gun))
            {
                return BadRequest(HataYaniti.Alan("tarih", "Tarih yyyy-MM-dd biçiminde olmalıdır."));
            }

            var menu = await _context.YemekMenuleri.AsNoTracking().FirstOrDefaultAsync(m => m.Tarih == gun);
            return menu == null ? NotFound(new HataYaniti("Bu gün için menü yok.")) : Ok(MenuyuDonustur(menu));
        }

        // Verilen tarihin içinde olduğu haftanın (pazartesi-cuma) menüleri.
        [HttpGet("haftalik")]
        [ProducesResponseType<List<YemekMenusuBilgisi>>(StatusCodes.Status200OK)]
        [ProducesResponseType<HataYaniti>(StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> Haftalik([FromQuery] string? tarih)
        {
            if (!TarihiCoz(tarih, out var gun))
            {
                return BadRequest(HataYaniti.Alan("tarih", "Tarih yyyy-MM-dd biçiminde olmalıdır."));
            }

            var haftaBasi = gun.AddDays(-(((int)gun.DayOfWeek + 6) % 7));
            var haftaSonu = haftaBasi.AddDays(6);

            var menuler = await _context.YemekMenuleri
                .AsNoTracking()
                .Where(m => m.Tarih >= haftaBasi && m.Tarih <= haftaSonu)
                .OrderBy(m => m.Tarih)
                .ToListAsync();

            return Ok(menuler.Select(MenuyuDonustur));
        }

        [HttpGet("kantinler")]
        [ProducesResponseType<List<KantinBilgisi>>(StatusCodes.Status200OK)]
        public async Task<IActionResult> Kantinler()
        {
            var kantinler = await _context.Mekanlar
                .AsNoTracking()
                .Where(m => m.Tur == MekanTuru.Kantin)
                .Include(m => m.Urunler)
                .OrderBy(m => m.Ad)
                .ToListAsync();

            return Ok(kantinler.Select(KantiniDonustur));
        }

        // Yemekhanenin bulunduğu bina(lar); mobil uygulama "Haritada göster" için kullanır.
        [HttpGet("binalar")]
        [ProducesResponseType<List<YemekhaneBinasi>>(StatusCodes.Status200OK)]
        public async Task<IActionResult> Binalar()
        {
            var binalar = await _context.Mekanlar
                .AsNoTracking()
                .Where(m => m.Tur == MekanTuru.Yemekhane)
                .OrderBy(m => m.Ad)
                .Select(m => new YemekhaneBinasi(m.Id, m.Ad))
                .ToListAsync();

            return Ok(binalar);
        }

        [HttpGet("kantinler/{id:int}")]
        [ProducesResponseType<KantinBilgisi>(StatusCodes.Status200OK)]
        [ProducesResponseType<HataYaniti>(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> Kantin(int id)
        {
            var kantin = await _context.Mekanlar
                .AsNoTracking()
                .Include(m => m.Urunler)
                .FirstOrDefaultAsync(m => m.Id == id && m.Tur == MekanTuru.Kantin);

            return kantin == null ? NotFound(new HataYaniti("Kantin bulunamadı.")) : Ok(KantiniDonustur(kantin));
        }

        private static bool TarihiCoz(string? metin, out DateOnly gun)
        {
            if (string.IsNullOrWhiteSpace(metin))
            {
                gun = DateOnly.FromDateTime(KutuphaneKurallari.TurkiyeSaati(DateTime.UtcNow));
                return true;
            }

            return DateOnly.TryParseExact(metin, "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out gun);
        }

        private static YemekMenusuBilgisi MenuyuDonustur(YemekMenusu m) => new(
            m.Id,
            m.Tarih.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture),
            m.Corba,
            m.AnaYemek,
            m.YanYemek,
            m.Tatli,
            m.VejetaryenSecenek,
            m.Kalori);

        private static KantinBilgisi KantiniDonustur(Mekan m) => new(
            m.Id,
            m.Ad,
            m.Tur.ToString(),
            m.Urunler
                .OrderBy(u => u.Kategori)
                .ThenBy(u => u.Ad)
                .Select(u => new KantinUrunuBilgisi(u.Id, u.Ad, u.Kategori.ToString(), u.Fiyat, u.MevcutMu))
                .ToList());
    }
}
