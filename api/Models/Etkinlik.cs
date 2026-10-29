using System.ComponentModel.DataAnnotations;

namespace api.Models
{
    public class Etkinlik
    {
        public int Id { get; set; }

        [Required(ErrorMessage = "Başlık zorunludur.")]
        [StringLength(150, MinimumLength = 3, ErrorMessage = "Başlık {2}-{1} karakter arasında olmalıdır.")]
        [Display(Name = "Başlık")]
        public string Baslik { get; set; } = string.Empty;

        [Required(ErrorMessage = "Açıklama zorunludur.")]
        [StringLength(2000, ErrorMessage = "Açıklama en fazla {1} karakter olabilir.")]
        [DataType(DataType.MultilineText)]
        [Display(Name = "Açıklama")]
        public string Aciklama { get; set; } = string.Empty;

        [Required(ErrorMessage = "Topluluk adı zorunludur.")]
        [StringLength(100)]
        [Display(Name = "Topluluk")]
        public string ToplulukAdi { get; set; } = string.Empty;

        [Required(ErrorMessage = "Tarih zorunludur.")]
        [DataType(DataType.DateTime)]
        [Display(Name = "Tarih")]
        public DateTime Tarih { get; set; }

        [Required(ErrorMessage = "Konum zorunludur.")]
        [StringLength(150)]
        [Display(Name = "Konum")]
        public string Konum { get; set; } = string.Empty;
    }
}
