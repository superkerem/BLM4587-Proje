import 'package:flutter/material.dart';

// Ana sayfadaki kartlar, yan menü ve modül ekranları aynı listeyi kullanır;
// yeni bir modül eklenince yalnızca burası ve main.dart'taki rota değişir.
class Modul {
  const Modul({
    required this.baslik,
    required this.ikon,
    required this.rota,
    required this.aciklama,
  });

  final String baslik;
  final IconData ikon;
  final String rota;
  final String aciklama;
}

class Moduller {
  Moduller._();

  static const harita = Modul(
    baslik: 'Kampüs Haritası',
    ikon: Icons.map,
    rota: '/kampus/harita',
    aciklama: 'Fakülteleri, binaları ve önemli noktaları harita üzerinde görüntüleyin.',
  );

  static const derslikBul = Modul(
    baslik: 'Derslik Bulucu',
    ikon: Icons.meeting_room,
    rota: '/kampus/derslik-bul',
    aciklama: 'Dersliklerin hangi binada ve katta olduğunu kolayca bulun.',
  );

  static const kutuphane = Modul(
    baslik: 'Kütüphane',
    ikon: Icons.local_library,
    rota: '/kampus/kutuphane',
    aciklama: 'Kütüphane doluluk durumunu görün ve çalışma masası ayırın.',
  );

  static const yemekhane = Modul(
    baslik: 'Yemekhane/Kantin',
    ikon: Icons.restaurant,
    rota: '/kampus/yemekhane',
    aciklama: 'Günlük yemek menüsüne ve kantin bilgilerine göz atın.',
  );

  static const etkinlikler = Modul(
    baslik: 'Etkinlikler',
    ikon: Icons.event,
    rota: '/kampus/etkinlikler',
    aciklama: 'Kampüsteki konferans, seminer ve kulüp etkinliklerini takip edin.',
  );

  static const kayipEsya = Modul(
    baslik: 'Kayıp Eşya',
    ikon: Icons.search,
    rota: '/kampus/kayip-esya',
    aciklama: 'Kaybettiğiniz eşyaları bildirin, bulunan eşyaları inceleyin.',
  );

  static const hepsi = [harita, derslikBul, kutuphane, yemekhane, etkinlikler, kayipEsya];
}
