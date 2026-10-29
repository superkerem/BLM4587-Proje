// API'deki Data Annotations kurallarının (KayitIstegi, GirisIstegi) mobil karşılığı.
// Bu kontroller form gönderilmeden çalışır; API aynı kuralları tekrar kontrol eder.
class Dogrulayicilar {
  Dogrulayicilar._();

  static final RegExp _harf = RegExp(r'^[a-zA-ZçÇğĞıİöÖşŞüÜ ]+$');
  static final RegExp _ogrenciNo = RegExp(r'^\d{8,11}$');
  static final RegExp _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final RegExp _kucukHarf = RegExp(r'[a-zçğıöşü]');
  static final RegExp _rakam = RegExp(r'\d');

  // [Required]
  static String? zorunlu(String? deger, String alanAdi) {
    if (deger == null || deger.trim().isEmpty) return '$alanAdi zorunludur.';
    return null;
  }

  // [StringLength(max, MinimumLength = min)]
  static String? uzunluk(String? deger, String alanAdi, {int min = 0, required int max}) {
    final karakter = deger?.trim().length ?? 0;
    if (karakter < min || karakter > max) {
      return min > 0
          ? '$alanAdi $min-$max karakter arasında olmalıdır.'
          : '$alanAdi en fazla $max karakter olabilir.';
    }
    return null;
  }

  // Ad ve Soyad: [Required] + [StringLength(50, MinimumLength = 2)] + [RegularExpression]
  static String? adSoyad(String? deger, String alanAdi) {
    return zorunlu(deger, alanAdi) ??
        uzunluk(deger, alanAdi, min: 2, max: 50) ??
        (_harf.hasMatch(deger!.trim()) ? null : '$alanAdi yalnızca harf içerebilir.');
  }

  // Öğrenci no isteğe bağlı; doluysa 8-11 rakam olmalı.
  static String? ogrenciNo(String? deger) {
    if (deger == null || deger.trim().isEmpty) return null;
    return _ogrenciNo.hasMatch(deger.trim())
        ? null
        : 'Öğrenci numarası 8-11 haneli rakamlardan oluşmalıdır.';
  }

  // [Required] + [EmailAddress] + [StringLength(100)]
  static String? email(String? deger) {
    return zorunlu(deger, 'E-posta') ??
        uzunluk(deger, 'E-posta', max: 100) ??
        (_email.hasMatch(deger!.trim()) ? null : 'Geçerli bir e-posta adresi giriniz.');
  }

  // Kayıtta şifre: en az 8 karakter, en az bir küçük harf ve bir rakam.
  static String? sifre(String? deger) {
    if (deger == null || deger.isEmpty) return 'Şifre zorunludur.';
    if (deger.length < 8 || deger.length > 100) return 'Şifre en az 8 karakter olmalıdır.';
    if (!_kucukHarf.hasMatch(deger) || !_rakam.hasMatch(deger)) {
      return 'Şifre en az bir küçük harf ve bir rakam içermelidir.';
    }
    return null;
  }

  // [Compare(nameof(Sifre))]
  static String? sifreTekrar(String? deger, String sifre) {
    if (deger == null || deger.isEmpty) return 'Şifre tekrarı zorunludur.';
    return deger == sifre ? null : 'Şifreler eşleşmiyor.';
  }

  // Giriş: öğrenci no veya e-posta.
  static String? kullaniciAdiVeyaEmail(String? deger) {
    return zorunlu(deger, 'Öğrenci numarası veya e-posta') ??
        uzunluk(deger, 'Öğrenci numarası veya e-posta', max: 100);
  }

  // [Range(min, max)] - derslik kapasitesi, masa katı gibi sayısal alanlar için.
  static String? aralik(String? deger, String alanAdi, int min, int max) {
    final sayi = int.tryParse(deger?.trim() ?? '');
    if (sayi == null) return '$alanAdi bir sayı olmalıdır.';
    if (sayi < min || sayi > max) return '$alanAdi $min ile $max arasında olmalıdır.';
    return null;
  }

  // Ders modelindeki IValidatableObject kuralı: bitiş saati başlangıçtan sonra olmalı.
  static String? bitisSaati(int baslangicDakika, int bitisDakika) {
    return bitisDakika > baslangicDakika
        ? null
        : 'Bitiş saati başlangıç saatinden sonra olmalıdır.';
  }
}
