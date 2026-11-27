import 'package:flutter/foundation.dart';

class ApiSabitleri {
  ApiSabitleri._();

  // flutter run --dart-define=API_URL=http://192.168.1.20:5135 ile değiştirilebilir.
  static const String _tanimliAdres = String.fromEnvironment('API_URL');

  static String get baseUrl {
    if (_tanimliAdres.isNotEmpty) return _tanimliAdres;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5135';
    }
    return 'http://localhost:5135';
  }

  static const String kayit = '/api/hesap/kayit';
  static const String giris = '/api/hesap/giris';
  static const String ben = '/api/hesap/ben';
  static const String yonetimKullanicilar = '/api/yonetim/kullanicilar';
  static const String duyurular = '/api/duyurular';
  static const String kayipEsyalar = '/api/kayip-esyalar';
  static const String mekanlar = '/api/mekanlar';
  static const String dersProgrami = '/api/ders-programi';
  static const String derslerim = '/api/derslerim';
  static const String sinavlar = '/api/sinavlar';
  static const String yonetimSinavlar = '/api/yonetim/sinavlar';
  static const String kutuphaneMasalar = '/api/kutuphane/masalar';
  static const String kutuphaneDoluluk = '/api/kutuphane/doluluk';
  static const String rezervasyonlarim = '/api/kutuphane/rezervasyonlarim';
  static const String rezervasyonlar = '/api/kutuphane/rezervasyonlar';
  static const String yemekhaneMenu = '/api/yemekhane/menu';
  static const String yemekhaneHaftalik = '/api/yemekhane/haftalik';
  static const String kantinler = '/api/yemekhane/kantinler';
  static const String yemekhaneBinalari = '/api/yemekhane/binalar';

  static const Duration zamanAsimi = Duration(seconds: 15);
}
