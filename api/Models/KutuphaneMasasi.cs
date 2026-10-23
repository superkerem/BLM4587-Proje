namespace api.Models
{
    public class KutuphaneMasasi
    {
        public int Id { get; set; }
        public string MasaNo { get; set; } = string.Empty;
        public int Kat { get; set; }
        public bool DoluMu { get; set; } = false;
        public int? RezerveEdenKullaniciId { get; set; }
        public DateTime? RezervasyonBitis { get; set; }
    }
}