using System.ComponentModel.DataAnnotations;

namespace api.Models
{
    public class KutuphaneRezervasyonu
    {
        public int Id { get; set; }

        [Display(Name = "Masa")]
        public int MasaId { get; set; }
        public KutuphaneMasasi? Masa { get; set; }

        public int KullaniciId { get; set; }
        public Kullanici? Kullanici { get; set; }

        [Display(Name = "Başlangıç")]
        public DateTime Baslangic { get; set; }

        [Display(Name = "Bitiş")]
        public DateTime Bitis { get; set; }

        [Display(Name = "İptal Edildi mi?")]
        public bool IptalEdildiMi { get; set; }

        [Display(Name = "Erken Boşaltıldı mı?")]
        public bool BosaltildiMi { get; set; }

        public DateTime OlusturmaTarihi { get; set; } = DateTime.UtcNow;
    }
}
