using api.Dtos;
using api.Models;
using api.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.JsonWebTokens;

namespace api.Controllers
{
    [ApiController]
    [Route("api/hesap")]
    public class HesapController : ControllerBase
    {
        private readonly UserManager<Kullanici> _userManager;
        private readonly SignInManager<Kullanici> _signInManager;
        private readonly JwtServisi _jwtServisi;

        public HesapController(UserManager<Kullanici> userManager, SignInManager<Kullanici> signInManager, JwtServisi jwtServisi)
        {
            _userManager = userManager;
            _signInManager = signInManager;
            _jwtServisi = jwtServisi;
        }

        [HttpPost("kayit")]
        [ProducesResponseType<OturumYaniti>(StatusCodes.Status200OK)]
        [ProducesResponseType<HataYaniti>(StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> Kayit(KayitIstegi istek)
        {
            var ogrenciNo = string.IsNullOrWhiteSpace(istek.OgrenciNo) ? null : istek.OgrenciNo.Trim();

            if (ogrenciNo != null && await _userManager.Users.AnyAsync(k => k.OgrenciNo == ogrenciNo))
            {
                return BadRequest(HataYaniti.Alan("ogrenciNo", "Bu öğrenci numarası zaten kayıtlı."));
            }

            var kullanici = new Kullanici
            {
                UserName = istek.Email.Trim(),
                Email = istek.Email.Trim(),
                Ad = istek.Ad.Trim(),
                Soyad = istek.Soyad.Trim(),
                OgrenciNo = ogrenciNo
            };

            var sonuc = await _userManager.CreateAsync(kullanici, istek.Sifre);

            if (!sonuc.Succeeded)
            {
                return BadRequest(new HataYaniti("Kayıt oluşturulamadı.", IdentityHatalariniGrupla(sonuc)));
            }

            await _userManager.AddToRoleAsync(kullanici, Roller.Kullanici);

            // Web projesinde kayıttan sonra giriş yaptırılıyordu; burada da hemen token döner.
            return Ok(await OturumOlustur(kullanici));
        }

        [HttpPost("giris")]
        [ProducesResponseType<OturumYaniti>(StatusCodes.Status200OK)]
        [ProducesResponseType<HataYaniti>(StatusCodes.Status400BadRequest)]
        [ProducesResponseType<HataYaniti>(StatusCodes.Status401Unauthorized)]
        public async Task<IActionResult> Giris(GirisIstegi istek)
        {
            var giris = istek.KullaniciAdiVeyaEmail.Trim();

            Kullanici? kullanici = giris.Contains('@')
                ? await _userManager.FindByEmailAsync(giris)
                : await _userManager.Users.FirstOrDefaultAsync(k => k.OgrenciNo == giris);

            if (kullanici == null)
            {
                return Unauthorized(new HataYaniti("Kullanıcı bilgileri veya şifre hatalı."));
            }

            var sonuc = await _signInManager.CheckPasswordSignInAsync(kullanici, istek.Sifre, lockoutOnFailure: true);

            if (sonuc.IsLockedOut)
            {
                return Unauthorized(new HataYaniti("Çok fazla hatalı deneme yapıldı. Hesabınız 5 dakika kilitlendi."));
            }

            if (!sonuc.Succeeded)
            {
                return Unauthorized(new HataYaniti("Kullanıcı bilgileri veya şifre hatalı."));
            }

            return Ok(await OturumOlustur(kullanici));
        }

        [Authorize]
        [HttpGet("ben")]
        [ProducesResponseType<KullaniciBilgisi>(StatusCodes.Status200OK)]
        [ProducesResponseType<HataYaniti>(StatusCodes.Status401Unauthorized)]
        public async Task<IActionResult> Ben()
        {
            var id = User.FindFirst(JwtRegisteredClaimNames.Sub)?.Value;
            var kullanici = id == null ? null : await _userManager.FindByIdAsync(id);

            if (kullanici == null)
            {
                return Unauthorized(new HataYaniti("Oturum geçersiz. Lütfen tekrar giriş yapın."));
            }

            return Ok(await BilgiOlustur(kullanici));
        }

        private async Task<OturumYaniti> OturumOlustur(Kullanici kullanici)
        {
            var bilgi = await BilgiOlustur(kullanici);
            var (token, bitis) = _jwtServisi.TokenUret(kullanici, bilgi.Roller);
            return new OturumYaniti(token, bitis, bilgi);
        }

        private async Task<KullaniciBilgisi> BilgiOlustur(Kullanici k)
        {
            var roller = await _userManager.GetRolesAsync(k);
            return new KullaniciBilgisi(k.Id, k.Ad, k.Soyad, k.Email, k.OgrenciNo, roller, k.KayitTarihi);
        }

        // Identity hatalarını ilgili form alanının altına düşecek şekilde gruplar.
        private static Dictionary<string, string[]> IdentityHatalariniGrupla(IdentityResult sonuc)
        {
            return sonuc.Errors
                .GroupBy(h => h.Code switch
                {
                    var kod when kod.StartsWith("Password") => "sifre",
                    "DuplicateEmail" or "InvalidEmail" or "DuplicateUserName" or "InvalidUserName" => "email",
                    _ => string.Empty
                })
                .ToDictionary(g => g.Key, g => g.Select(h => h.Description).ToArray());
        }
    }
}
