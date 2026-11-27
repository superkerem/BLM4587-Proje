using System.ComponentModel.DataAnnotations;

namespace api.Models
{
    public class YemekMenusu
    {
        public int Id { get; set; }

        [Required(ErrorMessage = "Tarih zorunludur.")]
        [Display(Name = "Tarih")]
        public DateOnly Tarih { get; set; }

        [Required(ErrorMessage = "Çorba zorunludur.")]
        [StringLength(80, ErrorMessage = "Çorba en fazla {1} karakter olabilir.")]
        [Display(Name = "Çorba")]
        public string Corba { get; set; } = string.Empty;

        [Required(ErrorMessage = "Ana yemek zorunludur.")]
        [StringLength(80, ErrorMessage = "Ana yemek en fazla {1} karakter olabilir.")]
        [Display(Name = "Ana Yemek")]
        public string AnaYemek { get; set; } = string.Empty;

        [StringLength(80, ErrorMessage = "Yan yemek en fazla {1} karakter olabilir.")]
        [Display(Name = "Yan Yemek")]
        public string? YanYemek { get; set; }

        [StringLength(80, ErrorMessage = "Tatlı/meyve en fazla {1} karakter olabilir.")]
        [Display(Name = "Tatlı / Meyve")]
        public string? Tatli { get; set; }

        [StringLength(80, ErrorMessage = "Vejetaryen seçenek en fazla {1} karakter olabilir.")]
        [Display(Name = "Vejetaryen Seçenek")]
        public string? VejetaryenSecenek { get; set; }

        [Range(0, 3000, ErrorMessage = "Kalori {1} ile {2} arasında olmalıdır.")]
        [Display(Name = "Kalori (kcal)")]
        public int? Kalori { get; set; }
    }
}
