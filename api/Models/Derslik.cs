using System.ComponentModel.DataAnnotations;

namespace api.Models
{
    public class Derslik
    {
        public int Id { get; set; }

        // Derslik kodu, örn. "A-101"
        [Required(ErrorMessage = "Derslik kodu zorunludur.")]
        [StringLength(20)]
        [RegularExpression(@"^[A-ZÇĞİÖŞÜ0-9]+-?[0-9]+$", ErrorMessage = "Derslik kodu 'A-101' biçiminde olmalıdır.")]
        [Display(Name = "Derslik Kodu")]
        public string Ad { get; set; } = string.Empty;

        [Required(ErrorMessage = "Blok zorunludur.")]
        [StringLength(20)]
        [Display(Name = "Blok")]
        public string Blok { get; set; } = string.Empty;

        [Required(ErrorMessage = "Kat zorunludur.")]
        [StringLength(10)]
        [Display(Name = "Kat")]
        public string Kat { get; set; } = string.Empty;

        [Range(1, 1000, ErrorMessage = "Kapasite {1} ile {2} arasında olmalıdır.")]
        [Display(Name = "Kapasite")]
        public int Kapasite { get; set; }

        [Display(Name = "Müsait mi?")]
        public bool MusaitMi { get; set; } = true;

        public ICollection<Ders> Dersler { get; set; } = new List<Ders>();
    }
}
