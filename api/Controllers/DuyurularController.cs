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
    [Route("api/duyurular")]
    [Authorize]
    public class DuyurularController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public DuyurularController(ApplicationDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        [ProducesResponseType<List<DuyuruBilgisi>>(StatusCodes.Status200OK)]
        public async Task<IActionResult> Listele([FromQuery] int adet = 10)
        {
            adet = Math.Clamp(adet, 1, 100);

            var duyurular = await _context.Duyurular
                .Include(d => d.Yazar)
                .OrderByDescending(d => d.OnemliMi)
                .ThenByDescending(d => d.YayinTarihi)
                .Take(adet)
                .ToListAsync();

            return Ok(duyurular.Select(Donustur));
        }

        [HttpGet("{id:int}")]
        [ProducesResponseType<DuyuruBilgisi>(StatusCodes.Status200OK)]
        [ProducesResponseType<HataYaniti>(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> Getir(int id)
        {
            var duyuru = await _context.Duyurular.Include(d => d.Yazar).FirstOrDefaultAsync(d => d.Id == id);
            return duyuru == null ? NotFound(new HataYaniti("Duyuru bulunamadı.")) : Ok(Donustur(duyuru));
        }

        [HttpPost]
        [Authorize(Policy = Politikalar.SadeceYonetici)]
        [ProducesResponseType<DuyuruBilgisi>(StatusCodes.Status201Created)]
        [ProducesResponseType<HataYaniti>(StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> Ekle(DuyuruIstegi istek)
        {
            var duyuru = new Duyuru
            {
                Baslik = istek.Baslik.Trim(),
                Icerik = istek.Icerik.Trim(),
                OnemliMi = istek.OnemliMi,
                YayinTarihi = DateTime.UtcNow,
                YazarId = int.TryParse(User.FindFirst(JwtRegisteredClaimNames.Sub)?.Value, out var id) ? id : null
            };

            _context.Duyurular.Add(duyuru);
            await _context.SaveChangesAsync();
            await _context.Entry(duyuru).Reference(d => d.Yazar).LoadAsync();

            return CreatedAtAction(nameof(Getir), new { id = duyuru.Id }, Donustur(duyuru));
        }

        [HttpPut("{id:int}")]
        [Authorize(Policy = Politikalar.SadeceYonetici)]
        [ProducesResponseType<DuyuruBilgisi>(StatusCodes.Status200OK)]
        [ProducesResponseType<HataYaniti>(StatusCodes.Status400BadRequest)]
        [ProducesResponseType<HataYaniti>(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> Guncelle(int id, DuyuruIstegi istek)
        {
            var duyuru = await _context.Duyurular.Include(d => d.Yazar).FirstOrDefaultAsync(d => d.Id == id);
            if (duyuru == null)
            {
                return NotFound(new HataYaniti("Duyuru bulunamadı."));
            }

            duyuru.Baslik = istek.Baslik.Trim();
            duyuru.Icerik = istek.Icerik.Trim();
            duyuru.OnemliMi = istek.OnemliMi;
            await _context.SaveChangesAsync();

            return Ok(Donustur(duyuru));
        }

        [HttpDelete("{id:int}")]
        [Authorize(Policy = Politikalar.SadeceYonetici)]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType<HataYaniti>(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> Sil(int id)
        {
            var duyuru = await _context.Duyurular.FindAsync(id);
            if (duyuru == null)
            {
                return NotFound(new HataYaniti("Duyuru bulunamadı."));
            }

            _context.Duyurular.Remove(duyuru);
            await _context.SaveChangesAsync();
            return NoContent();
        }

        private static DuyuruBilgisi Donustur(Duyuru d) => new(
            d.Id,
            d.Baslik,
            d.Icerik,
            d.OnemliMi,
            d.YayinTarihi,
            d.Yazar != null ? $"{d.Yazar.Ad} {d.Yazar.Soyad}" : "Yönetim");
    }
}
