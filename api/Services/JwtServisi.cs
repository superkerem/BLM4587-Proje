using System.Security.Claims;
using System.Text;
using api.Models;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.JsonWebTokens;
using Microsoft.IdentityModel.Tokens;

namespace api.Services
{
    public class JwtAyarlari
    {
        public string Anahtar { get; set; } = string.Empty;
        public string Yayinci { get; set; } = string.Empty;
        public string Hedef { get; set; } = string.Empty;
        public int SureDakika { get; set; } = 120;
    }

    public class JwtServisi
    {
        private readonly JwtAyarlari _ayarlar;

        public JwtServisi(IOptions<JwtAyarlari> ayarlar)
        {
            _ayarlar = ayarlar.Value;
        }

        public (string Token, DateTime BitisZamani) TokenUret(Kullanici kullanici, IEnumerable<string> roller)
        {
            var bitis = DateTime.UtcNow.AddMinutes(_ayarlar.SureDakika);

            var claimler = new List<Claim>
            {
                new(JwtRegisteredClaimNames.Sub, kullanici.Id.ToString()),
                new(JwtRegisteredClaimNames.Email, kullanici.Email ?? string.Empty),
                new("name", $"{kullanici.Ad} {kullanici.Soyad}"),
                new(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString())
            };
            claimler.AddRange(roller.Select(rol => new Claim("role", rol)));

            var anahtar = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_ayarlar.Anahtar));

            var tanim = new SecurityTokenDescriptor
            {
                Subject = new ClaimsIdentity(claimler),
                Issuer = _ayarlar.Yayinci,
                Audience = _ayarlar.Hedef,
                Expires = bitis,
                SigningCredentials = new SigningCredentials(anahtar, SecurityAlgorithms.HmacSha256)
            };

            var token = new JsonWebTokenHandler().CreateToken(tanim);
            return (token, bitis);
        }
    }
}
