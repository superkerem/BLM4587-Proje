using System.ComponentModel.DataAnnotations;

namespace api.Dtos
{
    public class DuyuruIstegi
    {
        [Required(ErrorMessage = "Başlık zorunludur.")]
        [StringLength(150, MinimumLength = 3, ErrorMessage = "Başlık {2}-{1} karakter arasında olmalıdır.")]
        [Display(Name = "Başlık")]
        public string Baslik { get; set; } = string.Empty;

        [Required(ErrorMessage = "İçerik zorunludur.")]
        [StringLength(2000, ErrorMessage = "İçerik en fazla {1} karakter olabilir.")]
        [Display(Name = "İçerik")]
        public string Icerik { get; set; } = string.Empty;

        [Display(Name = "Önemli mi?")]
        public bool OnemliMi { get; set; }
    }

    public record DuyuruBilgisi(
        int Id,
        string Baslik,
        string Icerik,
        bool OnemliMi,
        DateTime YayinTarihi,
        string YazarAdi);
}
