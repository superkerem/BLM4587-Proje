import 'dart:async';

import 'package:flutter/material.dart';

import 'core/tema.dart';
import 'models/duyuru.dart';
import 'models/kayip_esya.dart';
import 'screens/ana_sayfa.dart';
import 'screens/erisim_engellendi_ekrani.dart';
import 'screens/giris_ekrani.dart';
import 'screens/kampus/derslik_bul_ekrani.dart';
import 'screens/kampus/etkinlikler_ekrani.dart';
import 'screens/kampus/harita_ekrani.dart';
import 'screens/kampus/kayip_esya_detay_ekrani.dart';
import 'screens/kampus/kayip_esya_ekrani.dart';
import 'screens/kampus/kayip_esya_form_ekrani.dart';
import 'screens/kampus/kutuphane_ekrani.dart';
import 'screens/kampus/yemekhane_ekrani.dart';
import 'screens/kayit_ekrani.dart';
import 'screens/yonetim/duyuru_form_ekrani.dart';
import 'screens/yonetim/duyurular_ekrani.dart';
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

  void _oturumDegisti() {
    if (_girisYapildi != _oturum.girisYapildi) {
      _girisYapildi = _oturum.girisYapildi;
      _navigatorKey.currentState?.popUntil((route) => route.isFirst);
    }
  }

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
          '/yonetim/duyurular' => const DuyurularEkrani(),
          '/yonetim/duyuru-form' => DuyuruFormEkrani(
              duyuru: ayarlar.arguments is Duyuru ? ayarlar.arguments as Duyuru : null,
            ),
          _ => const ErisimEngellendiEkrani(),
        };
      }
    } else if (ad.startsWith('/kampus')) {
      if (!_oturum.girisYapildi) {
        ekran = const GirisEkrani();
      } else {
        ekran = switch (ad) {
          '/kampus/harita' => HaritaEkrani(seciliMekanId: ayarlar.arguments is int ? ayarlar.arguments as int : null),
          '/kampus/derslik-bul' => const DerslikBulEkrani(),
          '/kampus/kutuphane' => const KutuphaneEkrani(),
          '/kampus/yemekhane' => const YemekhaneEkrani(),
          '/kampus/etkinlikler' => const EtkinliklerEkrani(),
          '/kampus/kayip-esya' => const KayipEsyaEkrani(),
          '/kampus/kayip-esya/detay' => switch (ayarlar.arguments) {
              final KayipEsya esya => KayipEsyaDetayEkrani(esya: esya),
              _ => const KayipEsyaEkrani(),
            },
          '/kampus/kayip-esya/form' => KayipEsyaFormEkrani(
              esya: ayarlar.arguments is KayipEsya ? ayarlar.arguments as KayipEsya : null,
            ),
          _ => const AnaSayfa(),
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
      theme: Tema.acik,
      home: ListenableBuilder(
        listenable: _oturum,
        builder: (context, _) => _oturum.girisYapildi ? const AnaSayfa() : const GirisEkrani(),
      ),
      onGenerateRoute: _rotaOlustur,
    );
  }
}
