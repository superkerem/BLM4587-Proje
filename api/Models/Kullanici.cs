using System.ComponentModel.DataAnnotations;

namespace api.Models
{
    // Öğrenci ve personel kullanıcıları. 2. haftada ASP.NET Core Identity'ye taşınacak.
    public class Kullanici
    {
        public int Id { get; set; }

        [StringLength(50)]
        public string Ad { get; set; } = string.Empty;

        [StringLength(50)]
        public string Soyad { get; set; } = string.Empty;

        // Sadece öğrenciler için dolu, personelde boş kalır.
        [StringLength(20)]
        public string? OgrenciNo { get; set; }

        [StringLength(100)]
        public string Email { get; set; } = string.Empty;

        public string SifreHash { get; set; } = string.Empty;

        // "Yonetici" veya "Kullanici"
        [StringLength(20)]
        public string Rol { get; set; } = "Kullanici";

        public DateTime KayitTarihi { get; set; } = DateTime.UtcNow;

        public ICollection<KutuphaneMasasi> RezerveMasalar { get; set; } = new List<KutuphaneMasasi>();
        public ICollection<KayipEsya> BildirilenEsyalar { get; set; } = new List<KayipEsya>();
    }
}
