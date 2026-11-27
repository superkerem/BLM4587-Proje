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
            else
            {
                await MekanTurleriniGuncelleAsync(context);
            }

            await DersPrograminiGuncelleAsync(context);

            if (!await context.Sinavlar.AnyAsync())
            {
                await SinavlariEkleAsync(context);
            }

            if (!await context.KutuphaneMasalari.AnyAsync())
            {
                await KutuphaneMasalariniEkleAsync(context);
            }

            if (!await context.YemekMenuleri.AnyAsync())
            {
                await YemekhaneVerisiniEkleAsync(context);
            }

            if (!await context.Etkinlikler.AnyAsync())
            {
                await EtkinlikleriEkleAsync(context);
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

        // Önceden oluşturulmuş veritabanlarında mekan türü değiştiyse (ör. SKS binası artık Yemekhane) günceller.
        private static async Task MekanTurleriniGuncelleAsync(ApplicationDbContext context)
        {
            using var belge = await DosyaOkuAsync("kampus_mekanlari.json");
            var mekanlar = await context.Mekanlar.ToDictionaryAsync(m => m.Id);

            foreach (var oge in belge.RootElement.EnumerateArray())
            {
                var id = oge.GetProperty("id").GetInt32();
                var tur = Enum.Parse<MekanTuru>(oge.GetProperty("tur").GetString()!);
                if (mekanlar.TryGetValue(id, out var mekan) && mekan.Tur != tur)
                {
                    mekan.Tur = tur;
                }
            }

            await context.SaveChangesAsync();
        }

        private static async Task DersPrograminiGuncelleAsync(ApplicationDbContext context)
        {
            using var belge = await DosyaOkuAsync("ders_programi.json");

            var derslikler = await context.Derslikler.ToDictionaryAsync(d => d.Id);
            foreach (var oge in belge.RootElement.GetProperty("derslikler").EnumerateArray())
            {
                var id = oge.GetProperty("id").GetInt32();
                if (!derslikler.TryGetValue(id, out var derslik))
                {
                    derslik = new Derslik { Id = id };
                    context.Derslikler.Add(derslik);
                }

                derslik.Ad = oge.GetProperty("ad").GetString()!;
                derslik.MekanId = SayiVeyaBos(oge.GetProperty("mekanId"));
                derslik.Not = oge.GetProperty("not").GetString();
            }

            await context.SaveChangesAsync();
            await SayaciGuncelleAsync(context, "Derslikler");

            var dersler = await context.Dersler.ToDictionaryAsync(d => d.Id);
            foreach (var oge in belge.RootElement.GetProperty("dersler").EnumerateArray())
            {
                var id = oge.GetProperty("id").GetInt32();
                if (!dersler.TryGetValue(id, out var ders))
                {
                    ders = new Ders { Id = id };
                    context.Dersler.Add(ders);
                }

                ders.Kod = oge.GetProperty("kod").GetString()!;
                ders.DersAdi = oge.GetProperty("dersAdi").GetString()!;
                ders.LabMi = oge.GetProperty("labMi").GetBoolean();
                ders.Grup = oge.GetProperty("grup").GetString()!;
                ders.Gun = oge.GetProperty("gun").GetInt32();
                ders.BaslangicSaati = Saat(oge.GetProperty("baslangic").GetString()!);
                ders.BitisSaati = Saat(oge.GetProperty("bitis").GetString()!);
                ders.DerslikId = SayiVeyaBos(oge.GetProperty("derslikId"));
            }

            await context.SaveChangesAsync();
            await SayaciGuncelleAsync(context, "Dersler");
        }

        private static async Task SinavlariEkleAsync(ApplicationDbContext context)
        {
            using var belge = await DosyaOkuAsync("sinav_programi.json");

            foreach (var oge in belge.RootElement.EnumerateArray())
            {
                context.Sinavlar.Add(new Sinav
                {
                    Id = oge.GetProperty("id").GetInt32(),
                    DersKodu = oge.GetProperty("dersKodu").GetString()!,
                    Tur = Enum.Parse<SinavTuru>(oge.GetProperty("tur").GetString()!),
                    Tarih = DateOnly.ParseExact(oge.GetProperty("tarih").GetString()!, "yyyy-MM-dd", CultureInfo.InvariantCulture),
                    BaslangicSaati = Saat(oge.GetProperty("baslangic").GetString()!),
                    BitisSaati = Saat(oge.GetProperty("bitis").GetString()!),
                    DerslikId = SayiVeyaBos(oge.GetProperty("derslikId"))
                });
            }

            await context.SaveChangesAsync();
            await SayaciGuncelleAsync(context, "Sinavlar");
        }

        private static async Task KutuphaneMasalariniEkleAsync(ApplicationDbContext context)
        {
            for (var i = 1; i <= 16; i++)
            {
                context.KutuphaneMasalari.Add(new KutuphaneMasasi
                {
                    MasaNo = $"1-{i:00}",
                    Kat = 1,
                    Kapasite = 1,
                    PrizVarMi = i % 2 == 0
                });
            }

            for (var i = 1; i <= 12; i++)
            {
                context.KutuphaneMasalari.Add(new KutuphaneMasasi
                {
                    MasaNo = $"2-{i:00}",
                    Kat = 2,
                    Kapasite = 1,
                    PrizVarMi = i <= 6
                });
            }

            for (var i = 1; i <= 4; i++)
            {
                context.KutuphaneMasalari.Add(new KutuphaneMasasi
                {
                    MasaNo = $"2-G{i}",
                    Kat = 2,
                    Kapasite = 4,
                    PrizVarMi = true
                });
            }

            await context.SaveChangesAsync();
        }

        // Dört haftalık menü sırası, ilk ve son gün arasındaki hafta içi günlere sırayla dağıtılır.
        private static async Task YemekhaneVerisiniEkleAsync(ApplicationDbContext context)
        {
            using var belge = await DosyaOkuAsync("yemekhane.json");
            var kok = belge.RootElement;

            var ilkGun = Tarih(kok.GetProperty("ilkGun").GetString()!);
            var sonGun = Tarih(kok.GetProperty("sonGun").GetString()!);
            var tatiller = kok.GetProperty("tatiller").EnumerateArray().Select(t => Tarih(t.GetString()!)).ToHashSet();
            var menuSirasi = kok.GetProperty("menuSirasi").EnumerateArray().ToList();

            var sira = 0;
            for (var gun = ilkGun; gun <= sonGun; gun = gun.AddDays(1))
            {
                if (gun.DayOfWeek is DayOfWeek.Saturday or DayOfWeek.Sunday || tatiller.Contains(gun))
                {
                    continue;
                }

                var oge = menuSirasi[sira % menuSirasi.Count];
                context.YemekMenuleri.Add(new YemekMenusu
                {
                    Tarih = gun,
                    Corba = oge.GetProperty("corba").GetString()!,
                    AnaYemek = oge.GetProperty("anaYemek").GetString()!,
                    YanYemek = oge.GetProperty("yanYemek").GetString(),
                    Tatli = oge.GetProperty("tatli").GetString(),
                    VejetaryenSecenek = oge.GetProperty("vejetaryen").GetString(),
                    Kalori = oge.GetProperty("kalori").GetInt32()
                });
                sira++;
            }

            var mekanIdleri = await context.Mekanlar.Select(m => m.Id).ToListAsync();
            foreach (var oge in kok.GetProperty("kantinUrunleri").EnumerateArray())
            {
                var mekanId = oge.GetProperty("mekanId").GetInt32();
                if (!mekanIdleri.Contains(mekanId))
                {
                    continue;
                }

                context.KantinUrunleri.Add(new KantinUrunu
                {
                    MekanId = mekanId,
                    Ad = oge.GetProperty("ad").GetString()!,
                    Kategori = Enum.Parse<UrunKategorisi>(oge.GetProperty("kategori").GetString()!),
                    Fiyat = oge.GetProperty("fiyat").GetDecimal(),
                    MevcutMu = oge.GetProperty("mevcutMu").GetBoolean()
                });
            }

            await context.SaveChangesAsync();
        }

        private static async Task EtkinlikleriEkleAsync(ApplicationDbContext context)
        {
            using var belge = await DosyaOkuAsync("etkinlikler.json");
            var mekanIdleri = await context.Mekanlar.Select(m => m.Id).ToListAsync();

            foreach (var oge in belge.RootElement.EnumerateArray())
            {
                var mekanId = SayiVeyaBos(oge.GetProperty("mekanId"));
                context.Etkinlikler.Add(new Etkinlik
                {
                    Baslik = oge.GetProperty("baslik").GetString()!,
                    Aciklama = oge.GetProperty("aciklama").GetString()!,
                    ToplulukAdi = oge.GetProperty("toplulukAdi").GetString()!,
                    Tarih = oge.GetProperty("tarih").GetDateTime().ToUniversalTime(),
                    Konum = oge.GetProperty("konum").GetString()!,
                    MekanId = mekanId is int id && mekanIdleri.Contains(id) ? id : null
                });
            }

            await context.SaveChangesAsync();
        }

        private static DateOnly Tarih(string metin) =>
            DateOnly.ParseExact(metin, "yyyy-MM-dd", CultureInfo.InvariantCulture);

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
