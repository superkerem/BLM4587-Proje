using System.ComponentModel.DataAnnotations;

namespace api.Models
{
    public class KullaniciDersi
    {
        public int Id { get; set; }

        public int KullaniciId { get; set; }
        public Kullanici? Kullanici { get; set; }

        [Required(ErrorMessage = "Ders kodu zorunludur.")]
        [StringLength(20)]
        [Display(Name = "Ders Kodu")]
        public string DersKodu { get; set; } = string.Empty;
    }
}
