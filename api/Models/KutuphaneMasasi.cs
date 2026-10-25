using System.ComponentModel.DataAnnotations;

namespace api.Models
{
    public class KutuphaneMasasi
    {
        public int Id { get; set; }

        [StringLength(20)]
        public string MasaNo { get; set; } = string.Empty;

        public int Kat { get; set; }
        public int Kapasite { get; set; } = 1;
        public bool PrizVarMi { get; set; }
        public bool DoluMu { get; set; } = false;

        public int? RezerveEdenKullaniciId { get; set; }
        public Kullanici? RezerveEdenKullanici { get; set; }

        public DateTime? RezervasyonBitis { get; set; }
    }
}
