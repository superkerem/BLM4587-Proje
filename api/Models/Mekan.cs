using System.ComponentModel.DataAnnotations;

namespace api.Models
{
    public enum MekanTuru
    {
        Fakulte,
        Kutuphane,
        Yemekhane,
        Kantin,
        RingDuragi,
        Yurt,
        Diger
    }

    public class Mekan
    {
        public int Id { get; set; }

        [StringLength(150, ErrorMessage = "Mekan adı en fazla {1} karakter olabilir.")]
        [Display(Name = "Mekan Adı")]
        public string? Ad { get; set; }

        [Display(Name = "Tür")]
        public MekanTuru Tur { get; set; }

        [Range(-90, 90, ErrorMessage = "Enlem {1} ile {2} arasında olmalıdır.")]
        public double Enlem { get; set; }

        [Range(-180, 180, ErrorMessage = "Boylam {1} ile {2} arasında olmalıdır.")]
        public double Boylam { get; set; }

        [Required(ErrorMessage = "Geometri zorunludur.")]
        public string Geometri { get; set; } = string.Empty;

        public ICollection<Derslik> Derslikler { get; set; } = new List<Derslik>();
    }
}
