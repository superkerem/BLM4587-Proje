using System.ComponentModel.DataAnnotations;

namespace api.Dtos
{
    public class KayitIstegi
    {
        [Required(ErrorMessage = "Ad zorunludur.")]
        [StringLength(50, MinimumLength = 2, ErrorMessage = "Ad {2}-{1} karakter arasında olmalıdır.")]
        [RegularExpression(@"^[a-zA-ZçÇğĞıİöÖşŞüÜ ]+$", ErrorMessage = "Ad yalnızca harf içerebilir.")]
        [Display(Name = "Ad")]
        public string Ad { get; set; } = string.Empty;

        [Required(ErrorMessage = "Soyad zorunludur.")]
        [StringLength(50, MinimumLength = 2, ErrorMessage = "Soyad {2}-{1} karakter arasında olmalıdır.")]
        [RegularExpression(@"^[a-zA-ZçÇğĞıİöÖşŞüÜ ]+$", ErrorMessage = "Soyad yalnızca harf içerebilir.")]
        [Display(Name = "Soyad")]
        public string Soyad { get; set; } = string.Empty;

        [RegularExpression(@"^\d{8,11}$", ErrorMessage = "Öğrenci numarası 8-11 haneli rakamlardan oluşmalıdır.")]
        [Display(Name = "Öğrenci No (personel boş bırakabilir)")]
        public string? OgrenciNo { get; set; }

        [Required(ErrorMessage = "E-posta zorunludur.")]
        [EmailAddress(ErrorMessage = "Geçerli bir e-posta adresi giriniz.")]
        [StringLength(100, ErrorMessage = "E-posta en fazla {1} karakter olabilir.")]
        [Display(Name = "E-posta")]
        public string Email { get; set; } = string.Empty;

        [Required(ErrorMessage = "Şifre zorunludur.")]
        [StringLength(100, MinimumLength = 8, ErrorMessage = "Şifre en az {2} karakter olmalıdır.")]
        [RegularExpression(@"^(?=.*[a-zçğıöşü])(?=.*\d).+$", ErrorMessage = "Şifre en az bir küçük harf ve bir rakam içermelidir.")]
        [DataType(DataType.Password)]
        [Display(Name = "Şifre")]
        public string Sifre { get; set; } = string.Empty;

        [Required(ErrorMessage = "Şifre tekrarı zorunludur.")]
        [Compare(nameof(Sifre), ErrorMessage = "Şifreler eşleşmiyor.")]
        [DataType(DataType.Password)]
        [Display(Name = "Şifre (Tekrar)")]
        public string SifreTekrar { get; set; } = string.Empty;
    }
}
