using System.Text.Json;
using api.Data;
using api.Dtos;
using api.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace api.Controllers
{
    [ApiController]
    [Route("api/mekanlar")]
    [Authorize]
    public class MekanlarController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public MekanlarController(ApplicationDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        [ProducesResponseType<List<MekanBilgisi>>(StatusCodes.Status200OK)]
        public async Task<IActionResult> Listele()
        {
            var mekanlar = await _context.Mekanlar
                .AsNoTracking()
                .Include(m => m.Derslikler)
                .OrderBy(m => m.Id)
                .ToListAsync();

            return Ok(mekanlar.Select(Donustur));
        }

        [HttpGet("{id:int}")]
        [ProducesResponseType<MekanBilgisi>(StatusCodes.Status200OK)]
        [ProducesResponseType<HataYaniti>(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> Getir(int id)
        {
            var mekan = await _context.Mekanlar
                .AsNoTracking()
                .Include(m => m.Derslikler)
                .FirstOrDefaultAsync(m => m.Id == id);

            return mekan == null ? NotFound(new HataYaniti("Mekan bulunamadı.")) : Ok(Donustur(mekan));
        }

        private static MekanBilgisi Donustur(Mekan m)
        {
            using var geometri = JsonDocument.Parse(m.Geometri);

            return new MekanBilgisi(
                m.Id,
                m.Ad,
                m.Tur.ToString(),
                m.Enlem,
                m.Boylam,
                geometri.RootElement.Clone(),
                m.Derslikler
                    .OrderBy(d => d.Ad)
                    .Select(d => new DerslikOzeti(d.Id, d.Ad, d.Not))
                    .ToList());
        }
    }
}
