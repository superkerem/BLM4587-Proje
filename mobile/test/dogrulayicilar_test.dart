import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/core/dogrulayicilar.dart';

void main() {
  group('Dogrulayicilar', () {
    test('ad yalnızca harf içerebilir', () {
      expect(Dogrulayicilar.adSoyad('Çağrı', 'Ad'), isNull);
      expect(Dogrulayicilar.adSoyad('Ali1', 'Ad'), 'Ad yalnızca harf içerebilir.');
      expect(Dogrulayicilar.adSoyad('A', 'Ad'), 'Ad 2-50 karakter arasında olmalıdır.');
      expect(Dogrulayicilar.adSoyad('', 'Ad'), 'Ad zorunludur.');
    });

    test('öğrenci no boş olabilir, doluysa 8-11 rakam', () {
      expect(Dogrulayicilar.ogrenciNo(''), isNull);
      expect(Dogrulayicilar.ogrenciNo('22290001'), isNull);
      expect(Dogrulayicilar.ogrenciNo('1234'), isNotNull);
      expect(Dogrulayicilar.ogrenciNo('12345678901a'), isNotNull);
    });

    test('e-posta biçimi', () {
      expect(Dogrulayicilar.email('ali@ankara.edu.tr'), isNull);
      expect(Dogrulayicilar.email('ali.ankara.edu.tr'), 'Geçerli bir e-posta adresi giriniz.');
    });

    test('şifre en az 8 karakter, küçük harf ve rakam içermeli', () {
      expect(Dogrulayicilar.sifre('sifre1234'), isNull);
      expect(Dogrulayicilar.sifre('kisa1'), 'Şifre en az 8 karakter olmalıdır.');
      expect(Dogrulayicilar.sifre('SADECEBUYUK1'), isNotNull);
      expect(Dogrulayicilar.sifre('rakamyokki'), isNotNull);
    });

    test('şifre tekrarı aynı olmalı', () {
      expect(Dogrulayicilar.sifreTekrar('abc12345', 'abc12345'), isNull);
      expect(Dogrulayicilar.sifreTekrar('abc12346', 'abc12345'), 'Şifreler eşleşmiyor.');
    });

    test('ders bitiş saati başlangıçtan sonra olmalı', () {
      expect(Dogrulayicilar.bitisSaati(9 * 60, 10 * 60), isNull);
      expect(Dogrulayicilar.bitisSaati(10 * 60, 9 * 60), isNotNull);
    });
  });
}
