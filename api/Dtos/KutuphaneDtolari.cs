using System.ComponentModel.DataAnnotations;
using api.Services;

namespace api.Dtos
{
    public class RezervasyonIstegi
    {
        [Range(1, int.MaxValue, ErrorMessage = "Bir masa seçmelisiniz.")]
        [Display(Name = "Masa")]
        public int MasaId { get; set; }

        [Required(ErrorMessage = "Tarih zorunludur.")]
        [RegularExpression(@"^\d{4}-\d{2}-\d{2}$", ErrorMessage = "Tarih YYYY-AA-GG biçiminde olmalıdır.")]
        [Display(Name = "Tarih")]
        public string Tarih { get; set; } = string.Empty;

        [Required(ErrorMessage = "Başlangıç saati zorunludur.")]
        [RegularExpression(@"^([01]\d|2[0-3]):(00|30)$", ErrorMessage = "Başlangıç saati SS:00 veya SS:30 biçiminde olmalıdır.")]
        [Display(Name = "Başlangıç Saati")]
        public string Baslangic { get; set; } = string.Empty;

        [Range(KutuphaneKurallari.EnKisaSureDakika, KutuphaneKurallari.EnUzunSureDakika,
            ErrorMessage = "Süre {1} ile {2} dakika arasında olmalıdır.")]
        [Display(Name = "Süre (dakika)")]
        public int SureDakika { get; set; }
    }

    public record MasaDurumu(int Id, string MasaNo, int Kat, int Kapasite, bool PrizVarMi, bool MusaitMi);

    public record KatDolulugu(int Kat, int Toplam, int Dolu);

    public record DolulukBilgisi(string Saat, bool AcikMi, int ToplamMasa, int DoluMasa, int Oran, List<KatDolulugu> Katlar);

    public record RezervasyonBilgisi(
        int Id,
        int MasaId,
        string MasaNo,
        int Kat,
        string Tarih,
        string Baslangic,
        string Bitis,
        string Durum);
}
