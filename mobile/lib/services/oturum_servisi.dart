import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../core/constants/api_constants.dart';
import '../models/kullanici.dart';
import 'api_istemcisi.dart';

// Giriş durumunu tutar. Ekranlar bu sınıfı dinleyerek giriş yapılıp yapılmadığına
// ve kullanıcının rolüne göre farklı içerik gösterir (web'deki _GirisPartial gibi).
class OturumServisi extends ChangeNotifier {
  OturumServisi._() {
    api.oturumSonlandi = () => cikisYap();
  }

  static final OturumServisi ornek = OturumServisi._();

  static const _tokenAnahtari = 'jwt_token';
  static const _kullaniciAnahtari = 'kullanici';

  final ApiIstemcisi api = ApiIstemcisi();
  final FlutterSecureStorage _depo = const FlutterSecureStorage();

  Kullanici? _kullanici;
  Kullanici? get kullanici => _kullanici;

  bool get girisYapildi => _kullanici != null && api.token != null;
  bool get yoneticiMi => _kullanici?.yoneticiMi ?? false;

  // Uygulama açılışında: "Beni Hatırla" ile kaydedilmiş oturum varsa cihazdan okunur.
  Future<void> oturumuYukle() async {
    final token = await _depo.read(key: _tokenAnahtari);
    final kayitli = await _depo.read(key: _kullaniciAnahtari);
    if (token == null || kayitli == null) return;

    api.token = token;
    _kullanici = Kullanici.fromJson(jsonDecode(kayitli) as Map<String, dynamic>);
  }

  // Açılıştan sonra arka planda: token hâlâ geçerli mi, roller değişti mi?
  Future<void> oturumuDogrula() async {
    if (api.token == null) return;
    try {
      final json = await api.get(ApiSabitleri.ben) as Map<String, dynamic>;
      _kullanici = Kullanici.fromJson(json);
      await _depo.write(key: _kullaniciAnahtari, value: jsonEncode(_kullanici!.toJson()));
      notifyListeners();
    } on ApiHatasi catch (hata) {
      // 401: süresi dolmuş token. Sunucuya ulaşılamadıysa son bilinen kullanıcıyla devam edilir.
      if (hata.yetkisiz) await cikisYap();
    }
  }

  Future<void> girisYap(String kullaniciAdiVeyaEmail, String sifre, {bool beniHatirla = false}) async {
    final json = await api.post(ApiSabitleri.giris, {
      'kullaniciAdiVeyaEmail': kullaniciAdiVeyaEmail.trim(),
      'sifre': sifre,
    }) as Map<String, dynamic>;

    await _oturumuBaslat(json, kalici: beniHatirla);
  }

  Future<void> kayitOl({
    required String ad,
    required String soyad,
    required String? ogrenciNo,
    required String email,
    required String sifre,
    required String sifreTekrar,
  }) async {
    final json = await api.post(ApiSabitleri.kayit, {
      'ad': ad.trim(),
      'soyad': soyad.trim(),
      'ogrenciNo': (ogrenciNo == null || ogrenciNo.trim().isEmpty) ? null : ogrenciNo.trim(),
      'email': email.trim(),
      'sifre': sifre,
      'sifreTekrar': sifreTekrar,
    }) as Map<String, dynamic>;

    await _oturumuBaslat(json, kalici: false);
  }

  // JWT sunucuda saklanmadığı için çıkış, token'ı cihazdan silmek demektir.
  Future<void> cikisYap() async {
    await _temizle();
    notifyListeners();
  }

  Future<void> _oturumuBaslat(Map<String, dynamic> json, {required bool kalici}) async {
    final token = json['token'] as String;
    _kullanici = Kullanici.fromJson(json['kullanici'] as Map<String, dynamic>);
    api.token = token;

    if (kalici) {
      await _depo.write(key: _tokenAnahtari, value: token);
      await _depo.write(key: _kullaniciAnahtari, value: jsonEncode(_kullanici!.toJson()));
    } else {
      await _depo.delete(key: _tokenAnahtari);
      await _depo.delete(key: _kullaniciAnahtari);
    }
    notifyListeners();
  }

  Future<void> _temizle() async {
    _kullanici = null;
    api.token = null;
    await _depo.delete(key: _tokenAnahtari);
    await _depo.delete(key: _kullaniciAnahtari);
  }
}
