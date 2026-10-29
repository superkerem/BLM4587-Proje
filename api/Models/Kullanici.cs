using System.ComponentModel.DataAnnotations;
using Microsoft.AspNetCore.Identity;

namespace api.Models
{
    public class Kullanici : IdentityUser<int>
    {
        [Required(ErrorMessage = "Ad zorunludur.")]
        [StringLength(50)]
        [Display(Name = "Ad")]
        public string Ad { get; set; } = string.Empty;

        [Required(ErrorMessage = "Soyad zorunludur.")]
        [StringLength(50)]
        [Display(Name = "Soyad")]
        public string Soyad { get; set; } = string.Empty;

        // Sadece öğrenciler için dolu, personelde boş kalır.
        [StringLength(20)]
        [Display(Name = "Öğrenci No")]
        public string? OgrenciNo { get; set; }

        public DateTime KayitTarihi { get; set; } = DateTime.UtcNow;

        public ICollection<KutuphaneMasasi> RezerveMasalar { get; set; } = new List<KutuphaneMasasi>();
        public ICollection<KayipEsya> BildirilenEsyalar { get; set; } = new List<KayipEsya>();
    }
}
