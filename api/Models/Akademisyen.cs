using System.ComponentModel.DataAnnotations;

namespace api.Models
{
    public class Akademisyen
    {
        public int Id { get; set; }

        [StringLength(50)]
        public string Ad { get; set; } = string.Empty;

        [StringLength(50)]
        public string Soyad { get; set; } = string.Empty;

        [StringLength(50)]
        public string Unvan { get; set; } = string.Empty;

        [StringLength(100)]
        public string Email { get; set; } = string.Empty;

        public ICollection<Ders> Dersler { get; set; } = new List<Ders>();
    }
}
