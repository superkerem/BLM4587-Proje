using System.ComponentModel.DataAnnotations;

namespace api.Models
{
    public enum SinavTuru
    {
        Vize,
        Final,
        Butunleme,
        Mazeret
    }

    public class Sinav : IValidatableObject
    {
        public int Id { get; set; }

        [Required(ErrorMessage = "Ders kodu zorunludur.")]
        [StringLength(20)]
        [Display(Name = "Ders Kodu")]
        public string DersKodu { get; set; } = string.Empty;

        [Display(Name = "Sınav Türü")]
        public SinavTuru Tur { get; set; }

        [Display(Name = "Tarih")]
        public DateOnly Tarih { get; set; }

        [Display(Name = "Başlangıç Saati")]
        public TimeOnly BaslangicSaati { get; set; }

        [Display(Name = "Bitiş Saati")]
        public TimeOnly BitisSaati { get; set; }

        [Display(Name = "Derslik")]
        public int? DerslikId { get; set; }
        public Derslik? Derslik { get; set; }

        public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
        {
            if (BitisSaati <= BaslangicSaati)
            {
                yield return new ValidationResult(
                    "Bitiş saati başlangıç saatinden sonra olmalıdır.",
                    new[] { nameof(BitisSaati) });
            }
        }
    }
}
