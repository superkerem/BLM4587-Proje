import '../core/turkiye_saati.dart';

class KutuphaneMasasi {
  const KutuphaneMasasi({
    required this.id,
    required this.masaNo,
    required this.kat,
    required this.kapasite,
    required this.prizVarMi,
    required this.musaitMi,
  });

  final int id;
  final String masaNo;
  final int kat;
  final int kapasite;
  final bool prizVarMi;
  final bool musaitMi;

  factory KutuphaneMasasi.fromJson(Map<String, dynamic> json) => KutuphaneMasasi(
        id: json['id'] as int,
        masaNo: json['masaNo'] as String? ?? '',
        kat: json['kat'] as int? ?? 0,
        kapasite: json['kapasite'] as int? ?? 1,
        prizVarMi: json['prizVarMi'] as bool? ?? false,
        musaitMi: json['musaitMi'] as bool? ?? false,
      );
}

class KatDolulugu {
  const KatDolulugu({required this.kat, required this.toplam, required this.dolu});

  final int kat;
  final int toplam;
  final int dolu;

  factory KatDolulugu.fromJson(Map<String, dynamic> json) => KatDolulugu(
        kat: json['kat'] as int? ?? 0,
        toplam: json['toplam'] as int? ?? 0,
        dolu: json['dolu'] as int? ?? 0,
      );
}

class KutuphaneDolulugu {
  const KutuphaneDolulugu({
    required this.saat,
    required this.acikMi,
    required this.toplamMasa,
    required this.doluMasa,
    required this.oran,
    required this.katlar,
  });

  final String saat;
  final bool acikMi;
  final int toplamMasa;
  final int doluMasa;
  final int oran;
  final List<KatDolulugu> katlar;

  factory KutuphaneDolulugu.fromJson(Map<String, dynamic> json) => KutuphaneDolulugu(
        saat: json['saat'] as String? ?? '',
        acikMi: json['acikMi'] as bool? ?? false,
        toplamMasa: json['toplamMasa'] as int? ?? 0,
        doluMasa: json['doluMasa'] as int? ?? 0,
        oran: json['oran'] as int? ?? 0,
        katlar: (json['katlar'] as List<dynamic>? ?? [])
            .map((e) => KatDolulugu.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

enum RezervasyonDurumu {
  yaklasan('Yaklasan', 'Yaklaşan'),
  devamEdiyor('DevamEdiyor', 'Devam ediyor'),
  tamamlandi('Tamamlandi', 'Tamamlandı');

  const RezervasyonDurumu(this.apiDegeri, this.etiket);

  final String apiDegeri;
  final String etiket;

  static RezervasyonDurumu coz(String? deger) {
    for (final durum in values) {
      if (durum.apiDegeri == deger) return durum;
    }
    return tamamlandi;
  }
}

class Rezervasyon {
  const Rezervasyon({
    required this.id,
    required this.masaNo,
    required this.kat,
    required this.tarih,
    required this.baslangic,
    required this.bitis,
    required this.durum,
  });

  final int id;
  final String masaNo;
  final int kat;
  final DateTime tarih;
  final int baslangic;
  final int bitis;
  final RezervasyonDurumu durum;

  int get sureDakika => bitis - baslangic;

  String get saatAraligi => '${TurkiyeSaati.saatMetni(baslangic)}–${TurkiyeSaati.saatMetni(bitis)}';

  factory Rezervasyon.fromJson(Map<String, dynamic> json) {
    final tarih = DateTime.parse(json['tarih'] as String);
    return Rezervasyon(
      id: json['id'] as int,
      masaNo: json['masaNo'] as String? ?? '',
      kat: json['kat'] as int? ?? 0,
      tarih: DateTime(tarih.year, tarih.month, tarih.day),
      baslangic: TurkiyeSaati.dakikayaCevir(json['baslangic'] as String),
      bitis: TurkiyeSaati.dakikayaCevir(json['bitis'] as String),
      durum: RezervasyonDurumu.coz(json['durum'] as String?),
    );
  }
}
