using System.ComponentModel.DataAnnotations;

namespace api.Models
{
    public class Duyuru
    {
        public int Id { get; set; }

        [Required(ErrorMessage = "Başlık zorunludur.")]
        [StringLength(150, MinimumLength = 3, ErrorMessage = "Başlık {2}-{1} karakter arasında olmalıdır.")]
        [Display(Name = "Başlık")]
        public string Baslik { get; set; } = string.Empty;

        [Required(ErrorMessage = "İçerik zorunludur.")]
        [StringLength(2000, ErrorMessage = "İçerik en fazla {1} karakter olabilir.")]
        [DataType(DataType.MultilineText)]
        [Display(Name = "İçerik")]
        public string Icerik { get; set; } = string.Empty;

        [Display(Name = "Önemli mi?")]
        public bool OnemliMi { get; set; }

        [Display(Name = "Yayın Tarihi")]
        public DateTime YayinTarihi { get; set; } = DateTime.UtcNow;

        public int? YazarId { get; set; }
        public Kullanici? Yazar { get; set; }
    }
}
