using api.Dtos;
using api.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace api.Controllers
{
    // Web projesindeki AuthorizeFolder("/Yonetim", "SadeceYonetici") kuralının API karşılığı.
    [ApiController]
    [Route("api/yonetim")]
    [Authorize(Policy = Politikalar.SadeceYonetici)]
    public class YonetimController : ControllerBase
    {
        private readonly UserManager<Kullanici> _userManager;

        public YonetimController(UserManager<Kullanici> userManager)
        {
            _userManager = userManager;
        }

        [HttpGet("kullanicilar")]
        [ProducesResponseType<List<KullaniciBilgisi>>(StatusCodes.Status200OK)]
        [ProducesResponseType<HataYaniti>(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType<HataYaniti>(StatusCodes.Status403Forbidden)]
        public async Task<IActionResult> Kullanicilar()
        {
            var kullanicilar = await _userManager.Users
                .OrderBy(k => k.KayitTarihi)
                .ToListAsync();

            var liste = new List<KullaniciBilgisi>();
            foreach (var k in kullanicilar)
            {
                var roller = await _userManager.GetRolesAsync(k);
                liste.Add(new KullaniciBilgisi(k.Id, k.Ad, k.Soyad, k.Email, k.OgrenciNo, roller, k.KayitTarihi));
            }

            return Ok(liste);
        }
    }
}
