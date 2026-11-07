using System.ComponentModel.DataAnnotations;

namespace api.Dtos
{
    public class KayipEsyaIstegi
    {
        [Required(ErrorMessage = "Başlık zorunludur.")]
        [StringLength(150, MinimumLength = 3, ErrorMessage = "Başlık {2}-{1} karakter arasında olmalıdır.")]
        [Display(Name = "Başlık")]
        public string Baslik { get; set; } = string.Empty;

        [Required(ErrorMessage = "Açıklama zorunludur.")]
        [StringLength(1000, ErrorMessage = "Açıklama en fazla {1} karakter olabilir.")]
        [DataType(DataType.MultilineText)]
        [Display(Name = "Açıklama")]
        public string Aciklama { get; set; } = string.Empty;

        [Required(ErrorMessage = "Bulunan yer zorunludur.")]
        [StringLength(150, ErrorMessage = "Bulunan yer en fazla {1} karakter olabilir.")]
        [Display(Name = "Bulunduğu Yer")]
        public string BulunanYer { get; set; } = string.Empty;

        [Required(ErrorMessage = "Bulunma tarihi zorunludur.")]
        [DataType(DataType.Date)]
        [Display(Name = "Bulunma Tarihi")]
        public DateTime? BulunmaTarihi { get; set; }

        [Display(Name = "Teslim Edildi mi?")]
        public bool TeslimEdildiMi { get; set; }
    }

    public record KayipEsyaBilgisi(
        int Id,
        string Baslik,
        string Aciklama,
        string BulunanYer,
        DateTime BulunmaTarihi,
        bool TeslimEdildiMi,
        int BildirenId,
        string BildirenAdi);
}
