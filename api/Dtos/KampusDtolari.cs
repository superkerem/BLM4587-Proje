using System.ComponentModel.DataAnnotations;
using System.Text.Json;

namespace api.Dtos
{
    public record DerslikOzeti(int Id, string Ad, string? Not);

    public record MekanBilgisi(
        int Id,
        string? Ad,
        string Tur,
        double Enlem,
        double Boylam,
        JsonElement Geometri,
        List<DerslikOzeti> Derslikler);

    public record DerslikBilgisi(int Id, string Ad, int? MekanId, string? MekanAdi, string? Not);

    public record DersBilgisi(
        int Id,
        string Kod,
        string DersAdi,
        bool LabMi,
        string Grup,
        int Gun,
        string Baslangic,
        string Bitis,
        int? DerslikId);

    public record DersProgramiYaniti(List<DerslikBilgisi> Derslikler, List<DersBilgisi> Dersler);

    public class DerslerimIstegi
    {
        [Required(ErrorMessage = "Ders listesi zorunludur.")]
        [MaxLength(40, ErrorMessage = "En fazla {1} ders seçilebilir.")]
        [Display(Name = "Ders Kodları")]
        public List<string> Kodlar { get; set; } = new();
    }

    public record SinavBilgisi(
        int Id,
        string DersKodu,
        string Tur,
        string Tarih,
        string Baslangic,
        string Bitis,
        int? DerslikId,
        string? DerslikAdi,
        int? MekanId,
        string? MekanAdi);
}
