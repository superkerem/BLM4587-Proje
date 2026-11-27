using System.ComponentModel.DataAnnotations;

namespace api.Models
{
    public enum UrunKategorisi
    {
        SicakIcecek,
        SogukIcecek,
        Yiyecek,
        Atistirmalik,
        Tatli
    }

    public class KantinUrunu
    {
        public int Id { get; set; }

        [Display(Name = "Kantin")]
        public int MekanId { get; set; }

        public Mekan? Mekan { get; set; }

        [Required(ErrorMessage = "Ürün adı zorunludur.")]
        [StringLength(80, MinimumLength = 2, ErrorMessage = "Ürün adı {2}-{1} karakter arasında olmalıdır.")]
        [Display(Name = "Ürün Adı")]
        public string Ad { get; set; } = string.Empty;

        [Display(Name = "Kategori")]
        public UrunKategorisi Kategori { get; set; }

        [Range(0, 10000, ErrorMessage = "Fiyat {1} ile {2} arasında olmalıdır.")]
        [Display(Name = "Fiyat (₺)")]
        public decimal Fiyat { get; set; }

        [Display(Name = "Satışta")]
        public bool MevcutMu { get; set; } = true;
    }
}
