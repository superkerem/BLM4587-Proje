import 'dart:async';

import 'package:flutter/material.dart';

import 'screens/ana_sayfa.dart';
import 'screens/erisim_engellendi_ekrani.dart';
import 'screens/giris_ekrani.dart';
import 'screens/kayit_ekrani.dart';
import 'screens/yonetim/kullanicilar_ekrani.dart';
import 'services/oturum_servisi.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await OturumServisi.ornek.oturumuYukle();
  runApp(const KampusPortaliApp());
  unawaited(OturumServisi.ornek.oturumuDogrula());
}

class KampusPortaliApp extends StatefulWidget {
  const KampusPortaliApp({super.key});

  @override
  State<KampusPortaliApp> createState() => _KampusPortaliAppState();
}

class _KampusPortaliAppState extends State<KampusPortaliApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  final _oturum = OturumServisi.ornek;
  late bool _girisYapildi = _oturum.girisYapildi;

  @override
  void initState() {
    super.initState();
    _oturum.addListener(_oturumDegisti);
  }

  @override
  void dispose() {
    _oturum.removeListener(_oturumDegisti);
    super.dispose();
  }

  // Giriş/çıkış olunca üstteki ekranlar (Kayıt, Yönetim) kapatılır;
  // kök ekranı ise aşağıdaki ListenableBuilder Giriş veya Ana Sayfa olarak seçer.
  void _oturumDegisti() {
    if (_girisYapildi != _oturum.girisYapildi) {
      _girisYapildi = _oturum.girisYapildi;
      _navigatorKey.currentState?.popUntil((route) => route.isFirst);
    }
  }

  // Web'deki AuthorizeFolder("/Yonetim", "SadeceYonetici") + LoginPath/AccessDeniedPath karşılığı.
  Route<dynamic> _rotaOlustur(RouteSettings ayarlar) {
    final ad = ayarlar.name ?? '/';
    Widget ekran;

    if (ad.startsWith('/yonetim')) {
      if (!_oturum.girisYapildi) {
        ekran = const GirisEkrani();
      } else if (!_oturum.yoneticiMi) {
        ekran = const ErisimEngellendiEkrani();
      } else {
        ekran = switch (ad) {
          '/yonetim/kullanicilar' => const KullanicilarEkrani(),
          _ => const ErisimEngellendiEkrani(),
        };
      }
    } else {
      ekran = switch (ad) {
        '/kayit' => const KayitEkrani(),
        '/erisim-engellendi' => const ErisimEngellendiEkrani(),
        _ => _oturum.girisYapildi ? const AnaSayfa() : const GirisEkrani(),
      };
    }

    return MaterialPageRoute(builder: (_) => ekran, settings: ayarlar);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AÜ Hub Mobil',
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigatorKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue.shade700),
        useMaterial3: true,
      ),
      home: ListenableBuilder(
        listenable: _oturum,
        builder: (context, _) => _oturum.girisYapildi ? const AnaSayfa() : const GirisEkrani(),
      ),
      onGenerateRoute: _rotaOlustur,
    );
  }
}
