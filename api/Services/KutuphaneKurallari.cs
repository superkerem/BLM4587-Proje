namespace api.Services
{
    public static class KutuphaneKurallari
    {
        public const int AcilisDakikasi = 8 * 60;
        public const int KapanisDakikasi = 22 * 60;
        public const int AdimDakika = 30;
        public const int EnKisaSureDakika = 30;
        public const int EnUzunSureDakika = 180;
        public const int GunlukToplamDakika = 300;
        public const int IleriGunSayisi = 7;

        public static readonly TimeZoneInfo SaatDilimi = TimeZoneInfo.FindSystemTimeZoneById("Europe/Istanbul");

        public static DateTime TurkiyeSaati(DateTime utc) =>
            TimeZoneInfo.ConvertTimeFromUtc(DateTime.SpecifyKind(utc, DateTimeKind.Utc), SaatDilimi);

        public static DateTime Utc(DateOnly tarih, int dakika) =>
            TimeZoneInfo.ConvertTimeToUtc(
                tarih.ToDateTime(TimeOnly.MinValue, DateTimeKind.Unspecified).AddMinutes(dakika),
                SaatDilimi);

        public static (DateTime Basi, DateTime Sonu) GunAraligiUtc(DateOnly tarih) =>
            (Utc(tarih, 0), Utc(tarih.AddDays(1), 0));

        public static int Dakika(TimeOnly saat) => saat.Hour * 60 + saat.Minute;

        public static int Dakika(DateTime zaman) => zaman.Hour * 60 + zaman.Minute;

        public static bool AcikMi(DateTime simdiUtc)
        {
            var dakika = Dakika(TurkiyeSaati(simdiUtc));
            return dakika >= AcilisDakikasi && dakika < KapanisDakikasi;
        }

        public static (string Alan, string Mesaj)? Denetle(DateOnly tarih, TimeOnly baslangic, int sureDakika, DateTime simdiUtc)
        {
            var baslangicDakikasi = Dakika(baslangic);

            if (sureDakika < EnKisaSureDakika || sureDakika > EnUzunSureDakika || sureDakika % AdimDakika != 0)
            {
                return ("sureDakika", "Süre 30 dakika ile 3 saat arasında, yarım saatlik adımlarla seçilmelidir.");
            }

            if (baslangicDakikasi % AdimDakika != 0 || baslangic.Second != 0)
            {
                return ("baslangic", "Başlangıç saati yarım saatlik adımlarla seçilmelidir.");
            }

            if (baslangicDakikasi < AcilisDakikasi)
            {
                return ("baslangic", "Kütüphane 08:00'de açılır.");
            }

            if (baslangicDakikasi + sureDakika > KapanisDakikasi)
            {
                return ("sureDakika", "Rezervasyon kütüphanenin kapanış saati olan 22:00'yi aşamaz.");
            }

            var simdi = TurkiyeSaati(simdiUtc);
            var bugun = DateOnly.FromDateTime(simdi);

            if (tarih < bugun)
            {
                return ("tarih", "Geçmiş bir güne rezervasyon yapılamaz.");
            }

            if (tarih > bugun.AddDays(IleriGunSayisi))
            {
                return ("tarih", "En fazla 7 gün sonrası için rezervasyon yapılabilir.");
            }

            var simdikiDilim = Dakika(simdi) - Dakika(simdi) % AdimDakika;
            if (tarih == bugun && baslangicDakikasi < simdikiDilim)
            {
                return ("baslangic", "Geçmiş bir saate rezervasyon yapılamaz.");
            }

            return null;
        }
    }
}
