namespace api.Dtos
{
    public record YemekMenusuBilgisi(
        int Id,
        string Tarih,
        string Corba,
        string AnaYemek,
        string? YanYemek,
        string? Tatli,
        string? VejetaryenSecenek,
        int? Kalori);

    public record KantinUrunuBilgisi(int Id, string Ad, string Kategori, decimal Fiyat, bool MevcutMu);

    public record YemekhaneBinasi(int Id, string? Ad);

    public record KantinBilgisi(int Id, string? Ad, string Tur, List<KantinUrunuBilgisi> Urunler);
}
