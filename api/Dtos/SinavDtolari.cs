using System.ComponentModel.DataAnnotations;
using System.Globalization;

namespace api.Dtos
{
    public class SinavIstegi : IValidatableObject
    {
        [Required(ErrorMessage = "Ders seçiniz.")]
        [StringLength(20)]
        [RegularExpression(@"^[A-ZÇĞİÖŞÜ]{2,4}[0-9]{3,4}$", ErrorMessage = "Ders kodu 'BLM4581' biçiminde olmalıdır.")]
        [Display(Name = "Ders")]
        public string DersKodu { get; set; } = string.Empty;

        [Required(ErrorMessage = "Sınav türü seçiniz.")]
        [RegularExpression("^(Vize|Final|Butunleme|Mazeret)$", ErrorMessage = "Sınav türü Vize, Final, Bütünleme veya Mazeret olmalıdır.")]
        [Display(Name = "Sınav Türü")]
        public string Tur { get; set; } = string.Empty;

        [Required(ErrorMessage = "Tarih zorunludur.")]
        [RegularExpression(@"^\d{4}-\d{2}-\d{2}$", ErrorMessage = "Tarih YYYY-AA-GG biçiminde olmalıdır.")]
        [Display(Name = "Tarih")]
        public string Tarih { get; set; } = string.Empty;

        [Required(ErrorMessage = "Başlangıç saati zorunludur.")]
        [RegularExpression(@"^([01]\d|2[0-3]):[0-5]\d$", ErrorMessage = "Başlangıç saati SS:dd biçiminde olmalıdır.")]
        [Display(Name = "Başlangıç Saati")]
        public string Baslangic { get; set; } = string.Empty;

        [Required(ErrorMessage = "Bitiş saati zorunludur.")]
        [RegularExpression(@"^([01]\d|2[0-3]):[0-5]\d$", ErrorMessage = "Bitiş saati SS:dd biçiminde olmalıdır.")]
        [Display(Name = "Bitiş Saati")]
        public string Bitis { get; set; } = string.Empty;

        [Display(Name = "Derslikler")]
        public List<int> DerslikIdleri { get; set; } = new();

        public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
        {
            if (DerslikIdleri.Count == 0)
            {
                yield return new ValidationResult("En az bir derslik seçiniz.", new[] { nameof(DerslikIdleri) });
            }

            if (!DateOnly.TryParseExact(Tarih, "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out _))
            {
                yield return new ValidationResult("Geçerli bir tarih giriniz.", new[] { nameof(Tarih) });
            }

            if (TimeOnly.TryParseExact(Baslangic, "HH:mm", CultureInfo.InvariantCulture, DateTimeStyles.None, out var baslangic) &&
                TimeOnly.TryParseExact(Bitis, "HH:mm", CultureInfo.InvariantCulture, DateTimeStyles.None, out var bitis) &&
                bitis <= baslangic)
            {
                yield return new ValidationResult("Bitiş saati başlangıç saatinden sonra olmalıdır.", new[] { nameof(Bitis) });
            }
        }
    }

    public record SinavDersligi(int Id, string Ad, int? MekanId, string? MekanAdi);

    public record SinavGrubuBilgisi(
        int Id,
        string DersKodu,
        string DersAdi,
        string Tur,
        string Tarih,
        string Baslangic,
        string Bitis,
        List<SinavDersligi> Derslikler,
        bool TamamlandiMi);

    public record YonetimSinavlariYaniti(List<SinavGrubuBilgisi> Yaklasanlar, List<SinavGrubuBilgisi> Gecmisler);

    public record SinavDetayi(
        int Id,
        string DersKodu,
        string Tur,
        string Tarih,
        string Baslangic,
        string Bitis,
        List<int> DerslikIdleri);
}
