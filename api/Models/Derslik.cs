using System.ComponentModel.DataAnnotations;

namespace api.Models
{
    public class Derslik
    {
        public int Id { get; set; }

        [Required(ErrorMessage = "Derslik adı zorunludur.")]
        [StringLength(100, MinimumLength = 2, ErrorMessage = "Derslik adı {2}-{1} karakter arasında olmalıdır.")]
        [Display(Name = "Derslik Adı")]
        public string Ad { get; set; } = string.Empty;

        [Range(1, 1000, ErrorMessage = "Kapasite {1} ile {2} arasında olmalıdır.")]
        [Display(Name = "Kapasite")]
        public int? Kapasite { get; set; }

        [StringLength(200, ErrorMessage = "Not en fazla {1} karakter olabilir.")]
        [Display(Name = "Not")]
        public string? Not { get; set; }

        [Display(Name = "Bina")]
        public int? MekanId { get; set; }
        public Mekan? Mekan { get; set; }

        public ICollection<Ders> Dersler { get; set; } = new List<Ders>();
    }
}
