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

  static const Duration zamanAsimi = Duration(seconds: 15);
}
