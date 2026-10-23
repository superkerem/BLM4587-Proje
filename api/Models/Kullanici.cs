namespace api.Models
{
    public class Kullanici
    {
        public int Id { get; set; }
        public string Ad { get; set; } = string.Empty;
        public string Soyad { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string SifreHash { get; set; } = string.Empty; 
        public string Rol { get; set; } = "User";
        public DateTime KayitTarihi { get; set; } = DateTime.UtcNow;
    }
}