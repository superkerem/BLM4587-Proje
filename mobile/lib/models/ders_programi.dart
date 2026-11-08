import '../core/turkiye_saati.dart';

class Derslik {
  const Derslik({required this.id, required this.ad, this.mekanId, this.mekanAdi, this.not});

  final int id;
  final String ad;
  final int? mekanId;
  final String? mekanAdi;
  final String? not;

  bool get kampusteMi => mekanId != null;

  String get konumMetni => mekanAdi ?? not ?? 'Konum belirtilmemiş';

  factory Derslik.fromJson(Map<String, dynamic> json) => Derslik(
        id: json['id'] as int,
        ad: json['ad'] as String? ?? '',
        mekanId: json['mekanId'] as int?,
        mekanAdi: json['mekanAdi'] as String?,
        not: json['not'] as String?,
      );
}

class Ders {
  const Ders({
    required this.id,
    required this.kod,
    required this.dersAdi,
    required this.labMi,
    required this.grup,
    required this.gun,
    required this.baslangic,
    required this.bitis,
    this.derslikId,
  });

  final int id;
  final String kod;
  final String dersAdi;
  final bool labMi;
  final String grup;
  final int gun;
  final int baslangic;
  final int bitis;
  final int? derslikId;

  String get saatAraligi => '${TurkiyeSaati.saatMetni(baslangic)}–${TurkiyeSaati.saatMetni(bitis)}';

  bool devamEdiyorMu(DateTime zaman) {
    final dakika = TurkiyeSaati.dakika(zaman);
    return gun == zaman.weekday && baslangic <= dakika && dakika < bitis;
  }

  factory Ders.fromJson(Map<String, dynamic> json) => Ders(
        id: json['id'] as int,
        kod: json['kod'] as String? ?? '',
        dersAdi: json['dersAdi'] as String? ?? '',
        labMi: json['labMi'] as bool? ?? false,
        grup: json['grup'] as String? ?? '',
        gun: json['gun'] as int,
        baslangic: TurkiyeSaati.dakikayaCevir(json['baslangic'] as String),
        bitis: TurkiyeSaati.dakikayaCevir(json['bitis'] as String),
        derslikId: json['derslikId'] as int?,
      );
}

class DersSecenegi {
  const DersSecenegi({required this.kod, required this.ad, required this.grup});

  final String kod;
  final String ad;
  final String grup;
}

class DersProgrami {
  DersProgrami({required this.derslikler, required this.dersler}) {
    for (final derslik in derslikler) {
      _derslikHaritasi[derslik.id] = derslik;
    }
    for (final ders in dersler) {
      final mevcut = _adlar[ders.kod];
      if (mevcut == null || (!ders.labMi && ders.dersAdi != ders.kod)) {
        _adlar[ders.kod] = ders.dersAdi;
      }
      _gruplar.putIfAbsent(ders.kod, () => ders.grup);
    }
  }

  final List<Derslik> derslikler;
  final List<Ders> dersler;
  final Map<int, Derslik> _derslikHaritasi = {};
  final Map<String, String> _adlar = {};
  final Map<String, String> _gruplar = {};

  Derslik? derslik(int? id) => id == null ? null : _derslikHaritasi[id];

  String dersAdi(String kod) => _adlar[kod] ?? kod;

  String etiket(String kod) {
    final ad = dersAdi(kod);
    return ad == kod ? kod : '$kod $ad';
  }

  List<DersSecenegi> get secenekler => [
        for (final kod in _gruplar.keys) DersSecenegi(kod: kod, ad: dersAdi(kod), grup: _gruplar[kod]!),
      ]..sort((a, b) => a.kod.compareTo(b.kod));

  List<Ders> oturumlar(Set<String> kodlar) => dersler.where((d) => kodlar.contains(d.kod)).toList()
    ..sort((a, b) => a.gun != b.gun ? a.gun.compareTo(b.gun) : a.baslangic.compareTo(b.baslangic));

  factory DersProgrami.fromJson(Map<String, dynamic> json) => DersProgrami(
        derslikler: (json['derslikler'] as List<dynamic>? ?? [])
            .map((e) => Derslik.fromJson(e as Map<String, dynamic>))
            .toList(),
        dersler: (json['dersler'] as List<dynamic>? ?? [])
            .map((e) => Ders.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

enum SinavTuru {
  vize('Vize', 'Vize'),
  finalSinavi('Final', 'Final'),
  butunleme('Butunleme', 'Bütünleme'),
  mazeret('Mazeret', 'Mazeret');

  const SinavTuru(this.apiDegeri, this.etiket);

  final String apiDegeri;
  final String etiket;

  static SinavTuru coz(String? deger) {
    for (final tur in values) {
      if (tur.apiDegeri == deger) return tur;
    }
    return vize;
  }
}

class Sinav {
  const Sinav({
    required this.id,
    required this.dersKodu,
    required this.tur,
    required this.tarih,
    required this.baslangic,
    required this.bitis,
    this.derslikAdi,
    this.mekanId,
    this.mekanAdi,
  });

  final int id;
  final String dersKodu;
  final SinavTuru tur;
  final DateTime tarih;
  final int baslangic;
  final int bitis;
  final String? derslikAdi;
  final int? mekanId;
  final String? mekanAdi;

  factory Sinav.fromJson(Map<String, dynamic> json) {
    final tarih = DateTime.parse(json['tarih'] as String);
    return Sinav(
      id: json['id'] as int,
      dersKodu: json['dersKodu'] as String? ?? '',
      tur: SinavTuru.coz(json['tur'] as String?),
      tarih: DateTime(tarih.year, tarih.month, tarih.day),
      baslangic: TurkiyeSaati.dakikayaCevir(json['baslangic'] as String),
      bitis: TurkiyeSaati.dakikayaCevir(json['bitis'] as String),
      derslikAdi: json['derslikAdi'] as String?,
      mekanId: json['mekanId'] as int?,
      mekanAdi: json['mekanAdi'] as String?,
    );
  }
}
