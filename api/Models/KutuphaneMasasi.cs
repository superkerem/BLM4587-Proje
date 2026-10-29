using System.ComponentModel.DataAnnotations;

namespace api.Models
{
    public class KutuphaneMasasi
    {
        public int Id { get; set; }

        [Required(ErrorMessage = "Masa numarası zorunludur.")]
        [StringLength(20)]
        [Display(Name = "Masa No")]
        public string MasaNo { get; set; } = string.Empty;

        [Range(-2, 10, ErrorMessage = "Kat {1} ile {2} arasında olmalıdır.")]
        [Display(Name = "Kat")]
        public int Kat { get; set; }

        [Range(1, 12, ErrorMessage = "Kapasite {1} ile {2} arasında olmalıdır.")]
        [Display(Name = "Kapasite")]
        public int Kapasite { get; set; } = 1;

        [Display(Name = "Priz Var mı?")]
        public bool PrizVarMi { get; set; }

        [Display(Name = "Dolu mu?")]
        public bool DoluMu { get; set; } = false;

        public int? RezerveEdenKullaniciId { get; set; }
        public Kullanici? RezerveEdenKullanici { get; set; }

        [Display(Name = "Rezervasyon Bitişi")]
        public DateTime? RezervasyonBitis { get; set; }
    }
}
