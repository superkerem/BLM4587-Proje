namespace api.Models
{
    public class KayipEsya
    {
        public int Id { get; set; }
        public string Baslik { get; set; } = string.Empty;
        public string Aciklama { get; set; } = string.Empty;
        public string BulunanYer { get; set; } = string.Empty;
        public bool TeslimEdildiMi { get; set; } = false;
        public DateTime BulunmaTarihi { get; set; } = DateTime.UtcNow;
        public int BildirenKullaniciId { get; set; } 
    }
}