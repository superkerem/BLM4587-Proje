using System.ComponentModel.DataAnnotations;

namespace api.Models
{
    public class Etkinlik
    {
        public int Id { get; set; }

        [StringLength(150)]
        public string Baslik { get; set; } = string.Empty;

        public string Aciklama { get; set; } = string.Empty;

        [StringLength(100)]
        public string ToplulukAdi { get; set; } = string.Empty;

        public DateTime Tarih { get; set; }

        [StringLength(150)]
        public string Konum { get; set; } = string.Empty;
    }
}
