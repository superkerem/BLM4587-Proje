namespace api.Models
{
    public class Derslik
    {
        public int Id { get; set; }
        public string Ad { get; set; } = string.Empty;
        public string Blok { get; set; } = string.Empty;
        public string Kat { get; set; } = string.Empty;
        public int Kapasite { get; set; }
        public bool MusaitMi { get; set; } = true;
    }
}