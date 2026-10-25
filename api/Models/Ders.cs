using System.ComponentModel.DataAnnotations;

namespace api.Models
{
    // Ders programındaki tek bir ders oturumu (gün + saat aralığı + derslik).
    public class Ders
    {
        public int Id { get; set; }

        [StringLength(100)]
        public string DersAdi { get; set; } = string.Empty;

        public DayOfWeek Gun { get; set; }
        public TimeOnly BaslangicSaati { get; set; }
        public TimeOnly BitisSaati { get; set; }

        public int DerslikId { get; set; }
        public Derslik? Derslik { get; set; }

        public int AkademisyenId { get; set; }
        public Akademisyen? Akademisyen { get; set; }
    }
}
