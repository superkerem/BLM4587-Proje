using System.ComponentModel.DataAnnotations;

namespace api.Models
{
    public class Ders : IValidatableObject
    {
        public int Id { get; set; }

        [Required(ErrorMessage = "Ders kodu zorunludur.")]
        [StringLength(20, MinimumLength = 3, ErrorMessage = "Ders kodu {2}-{1} karakter arasında olmalıdır.")]
        [Display(Name = "Ders Kodu")]
        public string Kod { get; set; } = string.Empty;

        [Required(ErrorMessage = "Ders adı zorunludur.")]
        [StringLength(150, MinimumLength = 2, ErrorMessage = "Ders adı {2}-{1} karakter arasında olmalıdır.")]
        [Display(Name = "Ders Adı")]
        public string DersAdi { get; set; } = string.Empty;

        [Display(Name = "Laboratuvar mı?")]
        public bool LabMi { get; set; }

        [Required(ErrorMessage = "Grup zorunludur.")]
        [StringLength(50, ErrorMessage = "Grup en fazla {1} karakter olabilir.")]
        [Display(Name = "Grup")]
        public string Grup { get; set; } = string.Empty;

        [Range(1, 7, ErrorMessage = "Gün 1 (Pazartesi) ile 7 (Pazar) arasında olmalıdır.")]
        [Display(Name = "Gün")]
        public int Gun { get; set; }

        [Required(ErrorMessage = "Başlangıç saati zorunludur.")]
        [Display(Name = "Başlangıç Saati")]
        public TimeOnly BaslangicSaati { get; set; }

        [Required(ErrorMessage = "Bitiş saati zorunludur.")]
        [Display(Name = "Bitiş Saati")]
        public TimeOnly BitisSaati { get; set; }

        [Display(Name = "Derslik")]
        public int? DerslikId { get; set; }
        public Derslik? Derslik { get; set; }

        [Display(Name = "Akademisyen")]
        public int? AkademisyenId { get; set; }
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
