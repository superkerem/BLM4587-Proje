using System.ComponentModel.DataAnnotations;

namespace api.Models
{
    // Ders programındaki tek bir ders oturumu (gün + saat aralığı + derslik).
    public class Ders : IValidatableObject
    {
        public int Id { get; set; }

        [Required(ErrorMessage = "Ders adı zorunludur.")]
        [StringLength(100, MinimumLength = 2, ErrorMessage = "Ders adı {2}-{1} karakter arasında olmalıdır.")]
        [Display(Name = "Ders Adı")]
        public string DersAdi { get; set; } = string.Empty;

        [Display(Name = "Gün")]
        public DayOfWeek Gun { get; set; }

        [Required(ErrorMessage = "Başlangıç saati zorunludur.")]
        [Display(Name = "Başlangıç Saati")]
        public TimeOnly BaslangicSaati { get; set; }

        [Required(ErrorMessage = "Bitiş saati zorunludur.")]
        [Display(Name = "Bitiş Saati")]
        public TimeOnly BitisSaati { get; set; }

        [Range(1, int.MaxValue, ErrorMessage = "Lütfen bir derslik seçiniz.")]
        [Display(Name = "Derslik")]
        public int DerslikId { get; set; }
        public Derslik? Derslik { get; set; }

        [Range(1, int.MaxValue, ErrorMessage = "Lütfen bir akademisyen seçiniz.")]
        [Display(Name = "Akademisyen")]
        public int AkademisyenId { get; set; }
        public Akademisyen? Akademisyen { get; set; }

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
