using System.ComponentModel.DataAnnotations;

namespace api.Models
{
    public class Derslik
    {
        public int Id { get; set; }

        // Derslik kodu, örn. "A-101"
        [StringLength(20)]
        public string Ad { get; set; } = string.Empty;

        [StringLength(20)]
        public string Blok { get; set; } = string.Empty;

        [StringLength(10)]
        public string Kat { get; set; } = string.Empty;

        public int Kapasite { get; set; }
        public bool MusaitMi { get; set; } = true;

        public ICollection<Ders> Dersler { get; set; } = new List<Ders>();
    }
}
