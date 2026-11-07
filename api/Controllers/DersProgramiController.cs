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
    [Route("api")]
    [Authorize]
    public class DersProgramiController : ControllerBase
    {
        private static readonly TimeZoneInfo TurkiyeSaatDilimi = TimeZoneInfo.FindSystemTimeZoneById("Europe/Istanbul");

        private readonly ApplicationDbContext _context;

        public DersProgramiController(ApplicationDbContext context)
        {
            _context = context;
        }

        [HttpGet("ders-programi")]
        [ProducesResponseType<DersProgramiYaniti>(StatusCodes.Status200OK)]
        public async Task<IActionResult> ProgramiGetir()
        {
            var derslikler = await _context.Derslikler
                .AsNoTracking()
                .Include(d => d.Mekan)
                .OrderBy(d => d.Id)
                .Select(d => new DerslikBilgisi(d.Id, d.Ad, d.MekanId, d.Mekan != null ? d.Mekan.Ad : null, d.Not))
                .ToListAsync();

            var dersler = await _context.Dersler
                .AsNoTracking()
                .OrderBy(d => d.Gun)
                .ThenBy(d => d.BaslangicSaati)
                .ToListAsync();

            return Ok(new DersProgramiYaniti(
                derslikler,
                dersler.Select(d => new DersBilgisi(
                    d.Id,
                    d.Kod,
                    d.DersAdi,
                    d.LabMi,
                    d.Grup,
                    d.Gun,
                    d.BaslangicSaati.ToString("HH:mm"),
                    d.BitisSaati.ToString("HH:mm"),
                    d.DerslikId)).ToList()));
        }

        [HttpGet("derslerim")]
        [ProducesResponseType<List<string>>(StatusCodes.Status200OK)]
        [ProducesResponseType<HataYaniti>(StatusCodes.Status401Unauthorized)]
        public async Task<IActionResult> Derslerim()
        {
            if (KullaniciId() is not int kullaniciId)
            {
                return Unauthorized(new HataYaniti("Bu işlem için giriş yapmalısınız."));
            }

            return Ok(await KodlariGetirAsync(kullaniciId));
        }

        [HttpPut("derslerim")]
        [ProducesResponseType<List<string>>(StatusCodes.Status200OK)]
        [ProducesResponseType<HataYaniti>(StatusCodes.Status400BadRequest)]
        [ProducesResponseType<HataYaniti>(StatusCodes.Status401Unauthorized)]
        public async Task<IActionResult> DerslerimiKaydet(DerslerimIstegi istek)
        {
            if (KullaniciId() is not int kullaniciId)
            {
                return Unauthorized(new HataYaniti("Bu işlem için giriş yapmalısınız."));
            }

            var kodlar = istek.Kodlar
                .Where(k => !string.IsNullOrWhiteSpace(k))
                .Select(k => k.Trim().ToUpperInvariant())
                .Distinct()
                .ToList();

            var gecerliKodlar = await _context.Dersler
                .Where(d => kodlar.Contains(d.Kod))
                .Select(d => d.Kod)
                .Distinct()
                .ToListAsync();

            var bilinmeyen = kodlar.Except(gecerliKodlar).FirstOrDefault();
            if (bilinmeyen != null)
            {
                return BadRequest(HataYaniti.Alan("kodlar", $"Ders programında {bilinmeyen} kodlu ders yok."));
            }

            var eskiler = await _context.KullaniciDersleri
                .Where(kd => kd.KullaniciId == kullaniciId)
                .ToListAsync();

            _context.KullaniciDersleri.RemoveRange(eskiler.Where(kd => !kodlar.Contains(kd.DersKodu)));

            var mevcut = eskiler.Select(kd => kd.DersKodu).ToHashSet();
            _context.KullaniciDersleri.AddRange(kodlar
                .Where(k => !mevcut.Contains(k))
                .Select(k => new KullaniciDersi { KullaniciId = kullaniciId, DersKodu = k }));

            await _context.SaveChangesAsync();

            return Ok(await KodlariGetirAsync(kullaniciId));
        }

        [HttpGet("derslerim/sinavlar")]
        [ProducesResponseType<List<SinavBilgisi>>(StatusCodes.Status200OK)]
        [ProducesResponseType<HataYaniti>(StatusCodes.Status401Unauthorized)]
        public async Task<IActionResult> Sinavlarim()
        {
            if (KullaniciId() is not int kullaniciId)
            {
                return Unauthorized(new HataYaniti("Bu işlem için giriş yapmalısınız."));
            }

            var kodlar = await KodlariGetirAsync(kullaniciId);
            var bugun = DateOnly.FromDateTime(TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, TurkiyeSaatDilimi));

            var sinavlar = await _context.Sinavlar
                .AsNoTracking()
                .Include(s => s.Derslik)
                .ThenInclude(d => d!.Mekan)
                .Where(s => kodlar.Contains(s.DersKodu) && s.Tarih >= bugun)
                .OrderBy(s => s.Tarih)
                .ThenBy(s => s.BaslangicSaati)
                .ToListAsync();

            return Ok(sinavlar.Select(s => new SinavBilgisi(
                s.Id,
                s.DersKodu,
                s.Tur.ToString(),
                s.Tarih.ToString("yyyy-MM-dd"),
                s.BaslangicSaati.ToString("HH:mm"),
                s.BitisSaati.ToString("HH:mm"),
                s.DerslikId,
                s.Derslik?.Ad,
                s.Derslik?.MekanId,
                s.Derslik?.Mekan?.Ad)));
        }

        private int? KullaniciId() =>
            int.TryParse(User.FindFirst(JwtRegisteredClaimNames.Sub)?.Value, out var id) ? id : null;

        private Task<List<string>> KodlariGetirAsync(int kullaniciId) =>
            _context.KullaniciDersleri
                .Where(kd => kd.KullaniciId == kullaniciId)
                .OrderBy(kd => kd.DersKodu)
                .Select(kd => kd.DersKodu)
                .ToListAsync();
    }
}
