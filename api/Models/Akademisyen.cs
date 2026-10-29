using System.ComponentModel.DataAnnotations;

namespace api.Models
{
    public class Akademisyen
    {
        public int Id { get; set; }

        [Required(ErrorMessage = "Ad zorunludur.")]
        [StringLength(50, MinimumLength = 2, ErrorMessage = "Ad {2}-{1} karakter arasında olmalıdır.")]
        [Display(Name = "Ad")]
        public string Ad { get; set; } = string.Empty;

        [Required(ErrorMessage = "Soyad zorunludur.")]
        [StringLength(50, MinimumLength = 2, ErrorMessage = "Soyad {2}-{1} karakter arasında olmalıdır.")]
        [Display(Name = "Soyad")]
        public string Soyad { get; set; } = string.Empty;

        [Required(ErrorMessage = "Unvan zorunludur.")]
        [StringLength(50)]
        [Display(Name = "Unvan")]
        public string Unvan { get; set; } = string.Empty;

        [Required(ErrorMessage = "E-posta zorunludur.")]
        [EmailAddress(ErrorMessage = "Geçerli bir e-posta adresi giriniz.")]
        [StringLength(100)]
        [Display(Name = "E-posta")]
        public string Email { get; set; } = string.Empty;

        public ICollection<Ders> Dersler { get; set; } = new List<Ders>();
    }
}
