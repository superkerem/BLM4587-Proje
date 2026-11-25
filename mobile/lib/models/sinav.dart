import '../core/turkiye_saati.dart';

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

DateTime _tarihCoz(String metin) {
  final tarih = DateTime.parse(metin);
  return DateTime(tarih.year, tarih.month, tarih.day);
}

String sinavTarihMetni(DateTime tarih) =>
    '${tarih.year}-${tarih.month.toString().padLeft(2, '0')}-${tarih.day.toString().padLeft(2, '0')}';

class SinavDersligi {
  const SinavDersligi({required this.id, required this.ad, this.mekanId, this.mekanAdi});

  final int id;
  final String ad;
  final int? mekanId;
  final String? mekanAdi;

  factory SinavDersligi.fromJson(Map<String, dynamic> json) => SinavDersligi(
        id: json['id'] as int,
        ad: json['ad'] as String? ?? '',
        mekanId: json['mekanId'] as int?,
        mekanAdi: json['mekanAdi'] as String?,
      );
}

class Sinav {
  const Sinav({
    required this.id,
    required this.dersKodu,
    required this.dersAdi,
    required this.tur,
    required this.tarih,
    required this.baslangic,
    required this.bitis,
    required this.derslikler,
    required this.tamamlandiMi,
  });

  final int id;
  final String dersKodu;
  final String dersAdi;
  final SinavTuru tur;
  final DateTime tarih;
  final int baslangic;
  final int bitis;
  final List<SinavDersligi> derslikler;
  final bool tamamlandiMi;

  String get saatAraligi => '${TurkiyeSaati.saatMetni(baslangic)}–${TurkiyeSaati.saatMetni(bitis)}';

  String get derslikMetni =>
      derslikler.isEmpty ? 'Derslik belirtilmemiş' : derslikler.map((d) => d.ad).join(', ');

  String? get mekanMetni {
    final adlar = derslikler.map((d) => d.mekanAdi).whereType<String>().toSet();
    return adlar.isEmpty ? null : adlar.join(' · ');
  }

  int? get mekanId {
    for (final derslik in derslikler) {
      if (derslik.mekanId != null) return derslik.mekanId;
    }
    return null;
  }

  factory Sinav.fromJson(Map<String, dynamic> json) => Sinav(
        id: json['id'] as int,
        dersKodu: json['dersKodu'] as String? ?? '',
        dersAdi: json['dersAdi'] as String? ?? '',
        tur: SinavTuru.coz(json['tur'] as String?),
        tarih: _tarihCoz(json['tarih'] as String),
        baslangic: TurkiyeSaati.dakikayaCevir(json['baslangic'] as String),
        bitis: TurkiyeSaati.dakikayaCevir(json['bitis'] as String),
        derslikler: (json['derslikler'] as List<dynamic>? ?? [])
            .map((e) => SinavDersligi.fromJson(e as Map<String, dynamic>))
            .toList(),
        tamamlandiMi: json['tamamlandiMi'] as bool? ?? false,
      );
}

class SinavDetayi {
  const SinavDetayi({
    required this.id,
    required this.dersKodu,
    required this.tur,
    required this.tarih,
    required this.baslangic,
    required this.bitis,
    required this.derslikIdleri,
  });

  final int id;
  final String dersKodu;
  final SinavTuru tur;
  final DateTime tarih;
  final int baslangic;
  final int bitis;
  final Set<int> derslikIdleri;

  factory SinavDetayi.fromJson(Map<String, dynamic> json) => SinavDetayi(
        id: json['id'] as int,
        dersKodu: json['dersKodu'] as String? ?? '',
        tur: SinavTuru.coz(json['tur'] as String?),
        tarih: _tarihCoz(json['tarih'] as String),
        baslangic: TurkiyeSaati.dakikayaCevir(json['baslangic'] as String),
        bitis: TurkiyeSaati.dakikayaCevir(json['bitis'] as String),
        derslikIdleri: (json['derslikIdleri'] as List<dynamic>? ?? []).cast<int>().toSet(),
      );
}

class YonetimSinavlari {
  const YonetimSinavlari({required this.yaklasanlar, required this.gecmisler});

  final List<Sinav> yaklasanlar;
  final List<Sinav> gecmisler;

  bool get bosMu => yaklasanlar.isEmpty && gecmisler.isEmpty;

  static List<Sinav> _liste(dynamic deger) => (deger as List<dynamic>? ?? [])
      .map((e) => Sinav.fromJson(e as Map<String, dynamic>))
      .toList();

  factory YonetimSinavlari.fromJson(Map<String, dynamic> json) => YonetimSinavlari(
        yaklasanlar: _liste(json['yaklasanlar']),
        gecmisler: _liste(json['gecmisler']),
      );
}
