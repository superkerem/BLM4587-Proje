using Microsoft.AspNetCore.Identity;
using api.Models;

namespace api.Data
{
    public static class RolVeYoneticiTohumlama
    {
        public static async Task CalistirAsync(IServiceProvider servisler)
        {
            using var kapsam = servisler.CreateScope();
            var rolYoneticisi = kapsam.ServiceProvider.GetRequiredService<RoleManager<IdentityRole<int>>>();
            var kullaniciYoneticisi = kapsam.ServiceProvider.GetRequiredService<UserManager<Kullanici>>();
            var ayarlar = kapsam.ServiceProvider.GetRequiredService<IConfiguration>();
            var logger = kapsam.ServiceProvider.GetRequiredService<ILoggerFactory>().CreateLogger("Tohumlama");

            foreach (var rol in Roller.Tumu)
            {
                if (!await rolYoneticisi.RoleExistsAsync(rol))
                {
                    await rolYoneticisi.CreateAsync(new IdentityRole<int>(rol));
                }
            }

            var email = ayarlar["YoneticiHesabi:Email"];
            var sifre = ayarlar["YoneticiHesabi:Sifre"];

            if (string.IsNullOrWhiteSpace(email) || string.IsNullOrWhiteSpace(sifre))
            {
                logger.LogWarning("YoneticiHesabi ayarı bulunamadı, yönetici hesabı oluşturulmadı.");
                return;
            }

            var yonetici = await kullaniciYoneticisi.FindByEmailAsync(email);
            if (yonetici == null)
            {
                yonetici = new Kullanici
                {
                    UserName = email,
                    Email = email,
                    EmailConfirmed = true,
                    Ad = "Sistem",
                    Soyad = "Yöneticisi"
                };

                var sonuc = await kullaniciYoneticisi.CreateAsync(yonetici, sifre);
                if (!sonuc.Succeeded)
                {
                    logger.LogError("Yönetici oluşturulamadı: {Hatalar}",
                        string.Join(", ", sonuc.Errors.Select(h => h.Description)));
                    return;
                }
            }

            if (!await kullaniciYoneticisi.IsInRoleAsync(yonetici, Roller.Yonetici))
            {
                await kullaniciYoneticisi.AddToRoleAsync(yonetici, Roller.Yonetici);
            }
        }
    }
}
