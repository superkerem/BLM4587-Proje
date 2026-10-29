namespace api.Dtos
{
    public record KullaniciBilgisi(
        int Id,
        string Ad,
        string Soyad,
        string? Email,
        string? OgrenciNo,
        IList<string> Roller,
        DateTime KayitTarihi);

    public record OturumYaniti(string Token, DateTime BitisZamani, KullaniciBilgisi Kullanici);

    // Tüm hatalar mobil uygulamaya bu tek biçimde gider: genel mesaj + alan bazlı hatalar.
    public record HataYaniti(string Mesaj, Dictionary<string, string[]>? Hatalar = null)
    {
        public static HataYaniti Alan(string alan, string mesaj) =>
            new(mesaj, new Dictionary<string, string[]> { [alan] = new[] { mesaj } });
    }
}
