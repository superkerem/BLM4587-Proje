import 'package:latlong2/latlong.dart';

enum MekanTuru {
  fakulte('Fakulte', 'Akademik'),
  kutuphane('Kutuphane', 'Kütüphane'),
  yemekhane('Yemekhane', 'Yemekhane'),
  kantin('Kantin', 'Kantin'),
  ringDuragi('RingDuragi', 'Ring Durağı'),
  yurt('Yurt', 'Yurt'),
  diger('Diger', 'Diğer');

  const MekanTuru(this.apiDegeri, this.etiket);

  final String apiDegeri;
  final String etiket;

  static MekanTuru coz(String? deger) {
    for (final tur in values) {
      if (tur.apiDegeri == deger) return tur;
    }
    return diger;
  }
}

class CokgenParcasi {
  const CokgenParcasi({required this.dis, required this.delikler});

  final List<LatLng> dis;
  final List<List<LatLng>> delikler;
}

class DerslikOzeti {
  const DerslikOzeti({required this.id, required this.ad, this.not});

  final int id;
  final String ad;
  final String? not;

  factory DerslikOzeti.fromJson(Map<String, dynamic> json) => DerslikOzeti(
        id: json['id'] as int,
        ad: json['ad'] as String? ?? '',
        not: json['not'] as String?,
      );
}

class Mekan {
  const Mekan({
    required this.id,
    required this.ad,
    required this.tur,
    required this.konum,
    required this.parcalar,
    required this.derslikler,
  });

  final int id;
  final String? ad;
  final MekanTuru tur;
  final LatLng konum;
  final List<CokgenParcasi> parcalar;
  final List<DerslikOzeti> derslikler;

  bool get adsizMi => ad == null || ad!.trim().isEmpty;

  factory Mekan.fromJson(Map<String, dynamic> json) {
    return Mekan(
      id: json['id'] as int,
      ad: json['ad'] as String?,
      tur: MekanTuru.coz(json['tur'] as String?),
      konum: LatLng((json['enlem'] as num).toDouble(), (json['boylam'] as num).toDouble()),
      parcalar: _geometriCoz(json['geometri'] as Map<String, dynamic>?),
      derslikler: (json['derslikler'] as List<dynamic>? ?? [])
          .map((e) => DerslikOzeti.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  static List<CokgenParcasi> _geometriCoz(Map<String, dynamic>? geometri) {
    if (geometri == null) return const [];
    final koordinatlar = geometri['coordinates'] as List<dynamic>;
    final cokgenler = geometri['type'] == 'MultiPolygon' ? koordinatlar : [koordinatlar];

    return [
      for (final cokgen in cokgenler)
        if ((cokgen as List<dynamic>).isNotEmpty)
          CokgenParcasi(
            dis: _halkaCoz(cokgen.first as List<dynamic>),
            delikler: [for (final halka in cokgen.skip(1)) _halkaCoz(halka as List<dynamic>)],
          ),
    ];
  }

  static List<LatLng> _halkaCoz(List<dynamic> halka) => [
        for (final nokta in halka)
          LatLng(((nokta as List<dynamic>)[1] as num).toDouble(), (nokta[0] as num).toDouble()),
      ];
}
