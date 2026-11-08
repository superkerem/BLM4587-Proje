using System.Globalization;
using System.Text.Json;
using api.Models;
using Microsoft.EntityFrameworkCore;

namespace api.Data
{
    public static class KampusVerisiTohumlama
    {
        public static async Task CalistirAsync(IServiceProvider servisler)
        {
            using var kapsam = servisler.CreateScope();
            var context = kapsam.ServiceProvider.GetRequiredService<ApplicationDbContext>();

            if (!await context.Mekanlar.AnyAsync())
            {
                await MekanlariEkleAsync(context);
            }

            if (!await context.Derslikler.AnyAsync() && !await context.Dersler.AnyAsync())
            {
                await DersPrograminiEkleAsync(context);
            }
        }

        private static string DosyaYolu(string dosyaAdi) =>
            Path.Combine(AppContext.BaseDirectory, "Data", "Tohum", dosyaAdi);

        private static async Task<JsonDocument> DosyaOkuAsync(string dosyaAdi) =>
            JsonDocument.Parse(await File.ReadAllTextAsync(DosyaYolu(dosyaAdi)));

        private static async Task MekanlariEkleAsync(ApplicationDbContext context)
        {
            using (var belge = await DosyaOkuAsync("kampus_mekanlari.json"))
            {
                foreach (var oge in belge.RootElement.EnumerateArray())
                {
                    context.Mekanlar.Add(new Mekan
                    {
                        Id = oge.GetProperty("id").GetInt32(),
                        Ad = oge.GetProperty("ad").GetString(),
                        Tur = Enum.Parse<MekanTuru>(oge.GetProperty("tur").GetString()!),
                        Enlem = oge.GetProperty("enlem").GetDouble(),
                        Boylam = oge.GetProperty("boylam").GetDouble(),
                        Geometri = oge.GetProperty("geometri").GetRawText()
                    });
                }
            }

            await context.SaveChangesAsync();
            await SayaciGuncelleAsync(context, "Mekanlar");

            using (var belge = await DosyaOkuAsync("kampus_diger_binalar.geojson"))
            {
                foreach (var oge in belge.RootElement.GetProperty("features").EnumerateArray())
                {
                    var geometri = oge.GetProperty("geometry");
                    var (enlem, boylam) = Merkez(geometri);

                    context.Mekanlar.Add(new Mekan
                    {
                        Ad = null,
                        Tur = MekanTuru.Diger,
                        Enlem = enlem,
                        Boylam = boylam,
                        Geometri = geometri.GetRawText()
                    });
                }
            }

            await context.SaveChangesAsync();
        }

        private static async Task DersPrograminiEkleAsync(ApplicationDbContext context)
        {
            using var belge = await DosyaOkuAsync("ders_programi.json");

            foreach (var oge in belge.RootElement.GetProperty("derslikler").EnumerateArray())
            {
                context.Derslikler.Add(new Derslik
                {
                    Id = oge.GetProperty("id").GetInt32(),
                    Ad = oge.GetProperty("ad").GetString()!,
                    MekanId = SayiVeyaBos(oge.GetProperty("mekanId")),
                    Not = oge.GetProperty("not").GetString()
                });
            }

            await context.SaveChangesAsync();
            await SayaciGuncelleAsync(context, "Derslikler");

            foreach (var oge in belge.RootElement.GetProperty("dersler").EnumerateArray())
            {
                context.Dersler.Add(new Ders
                {
                    Id = oge.GetProperty("id").GetInt32(),
                    Kod = oge.GetProperty("kod").GetString()!,
                    DersAdi = oge.GetProperty("dersAdi").GetString()!,
                    LabMi = oge.GetProperty("labMi").GetBoolean(),
                    Grup = oge.GetProperty("grup").GetString()!,
                    Gun = oge.GetProperty("gun").GetInt32(),
                    BaslangicSaati = Saat(oge.GetProperty("baslangic").GetString()!),
                    BitisSaati = Saat(oge.GetProperty("bitis").GetString()!),
                    DerslikId = SayiVeyaBos(oge.GetProperty("derslikId"))
                });
            }

            await context.SaveChangesAsync();
            await SayaciGuncelleAsync(context, "Dersler");
        }

        private static int? SayiVeyaBos(JsonElement deger) =>
            deger.ValueKind == JsonValueKind.Number ? deger.GetInt32() : null;

        private static TimeOnly Saat(string metin) =>
            TimeOnly.ParseExact(metin, "HH:mm", CultureInfo.InvariantCulture);

        private static (double Enlem, double Boylam) Merkez(JsonElement geometri)
        {
            var koordinatlar = geometri.GetProperty("coordinates");
            var disHalka = geometri.GetProperty("type").GetString() == "MultiPolygon"
                ? koordinatlar[0][0]
                : koordinatlar[0];

            double toplamEnlem = 0, toplamBoylam = 0;
            var adet = 0;
            foreach (var nokta in disHalka.EnumerateArray())
            {
                toplamBoylam += nokta[0].GetDouble();
                toplamEnlem += nokta[1].GetDouble();
                adet++;
            }

            return (toplamEnlem / adet, toplamBoylam / adet);
        }

        private static Task SayaciGuncelleAsync(ApplicationDbContext context, string tablo)
        {
            var sorgu = "SELECT setval(pg_get_serial_sequence('\"" + tablo + "\"', 'Id'), (SELECT MAX(\"Id\") FROM \"" + tablo + "\"))";
            return context.Database.ExecuteSqlRawAsync(sorgu);
        }
    }
}
