import 'package:flutter/material.dart';

class Renkler {
  Renkler._();

  static const vurgu = Color(0xFF0E4A87);
  static const vurguKoyu = Color(0xFF0A3866);
  static const vurguAcik = Color(0xFFE8EFF7);
  static const arka = Color(0xFFF5F6F8);
  static const yuzey = Colors.white;
  static const kenar = Color(0xFFE1E4E8);
  static const yazi = Color(0xFF1F2328);
  static const yaziSoluk = Color(0xFF656D76);
}

class Tema {
  Tema._();

  static const double kose = 8;

  static ThemeData get acik {
    final renkSemasi = ColorScheme.fromSeed(
      seedColor: Renkler.vurgu,
      primary: Renkler.vurgu,
      surface: Renkler.yuzey,
    );

    final cerceve = OutlineInputBorder(
      borderRadius: BorderRadius.circular(kose),
      borderSide: const BorderSide(color: Renkler.kenar),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: renkSemasi,
      scaffoldBackgroundColor: Renkler.arka,
      appBarTheme: const AppBarTheme(
        backgroundColor: Renkler.yuzey,
        foregroundColor: Renkler.yazi,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        shape: Border(bottom: BorderSide(color: Renkler.kenar)),
        titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Renkler.yazi),
      ),
      cardTheme: CardThemeData(
        color: Renkler.yuzey,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kose),
          side: const BorderSide(color: Renkler.kenar),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Renkler.yuzey,
        border: cerceve,
        enabledBorder: cerceve,
        focusedBorder: cerceve.copyWith(borderSide: const BorderSide(color: Renkler.vurgu, width: 1.5)),
        prefixIconColor: Renkler.yaziSoluk,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Renkler.vurgu,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kose)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Renkler.yazi,
          side: const BorderSide(color: Renkler.kenar),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kose)),
        ),
      ),
      dividerTheme: const DividerThemeData(color: Renkler.kenar, space: 1),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    );
  }
}

class TurkceTarih {
  TurkceTarih._();

  static const aylar = [
    'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
    'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
  ];
  static const gunler = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];

  static String uzun(DateTime t) => '${t.day} ${aylar[t.month - 1]} ${t.year}, ${gunler[t.weekday - 1]}';

  static String saatli(DateTime t) =>
      '${t.day} ${aylar[t.month - 1]} ${t.year}, ${_iki(t.hour)}:${_iki(t.minute)}';

  static String kisaAy(DateTime t) => aylar[t.month - 1].substring(0, 3);

  static String _iki(int s) => s.toString().padLeft(2, '0');
}
