class YemekMenusu {
  final int id;
  final DateTime tarih;
  final String corba;
  final String anaYemek;
  final String? yanYemek;
  final String? tatli;
  final String? vejetaryenSecenek;
  final int? kalori;

  const YemekMenusu({
    required this.id,
    required this.tarih,
    required this.corba,
    required this.anaYemek,
    this.yanYemek,
    this.tatli,
    this.vejetaryenSecenek,
    this.kalori,
  });

  factory YemekMenusu.fromJson(Map<String, dynamic> json) {
    return YemekMenusu(
      id: json['id'] as int,
      tarih: DateTime.parse(json['tarih'] as String),
      corba: json['corba'] as String? ?? '',
      anaYemek: json['anaYemek'] as String? ?? '',
      yanYemek: json['yanYemek'] as String?,
      tatli: json['tatli'] as String?,
      vejetaryenSecenek: json['vejetaryenSecenek'] as String?,
      kalori: json['kalori'] as int?,
    );
  }
}

class KantinUrunu {
  final int id;
  final String ad;
  final String kategori;
  final double fiyat;
  final bool mevcutMu;

  const KantinUrunu({
    required this.id,
    required this.ad,
    required this.kategori,
    required this.fiyat,
    required this.mevcutMu,
  });

  factory KantinUrunu.fromJson(Map<String, dynamic> json) {
    return KantinUrunu(
      id: json['id'] as int,
      ad: json['ad'] as String? ?? '',
      kategori: json['kategori'] as String? ?? '',
      fiyat: (json['fiyat'] as num? ?? 0).toDouble(),
      mevcutMu: json['mevcutMu'] as bool? ?? true,
    );
  }

  // 45.0 -> "45,00 ₺"
  String get fiyatMetni => '${fiyat.toStringAsFixed(2).replaceAll('.', ',')} ₺';

  static const kategoriSirasi = ['SicakIcecek', 'SogukIcecek', 'Yiyecek', 'Atistirmalik', 'Tatli'];

  static String kategoriAdi(String kategori) => switch (kategori) {
        'SicakIcecek' => 'Sıcak İçecekler',
        'SogukIcecek' => 'Soğuk İçecekler',
        'Yiyecek' => 'Yiyecekler',
        'Atistirmalik' => 'Atıştırmalıklar',
        'Tatli' => 'Tatlılar',
        'Diger' => 'Diğer',
        _ => kategori,
      };
}

class Kantin {
  final int id;
  final String ad;
  final String tur;
  final List<KantinUrunu> urunler;

  const Kantin({required this.id, required this.ad, required this.tur, required this.urunler});

  factory Kantin.fromJson(Map<String, dynamic> json) {
    return Kantin(
      id: json['id'] as int,
      ad: json['ad'] as String? ?? 'Kantin',
      tur: json['tur'] as String? ?? 'Kantin',
      urunler: (json['urunler'] as List<dynamic>? ?? [])
          .map((e) => KantinUrunu.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // Ürünleri kategori sırasına göre gruplar; boş kategoriler atlanır.
  Map<String, List<KantinUrunu>> get kategoriler {
    final gruplar = <String, List<KantinUrunu>>{};
    for (final kategori in KantinUrunu.kategoriSirasi) {
      final liste = urunler.where((u) => u.kategori == kategori).toList();
      if (liste.isNotEmpty) gruplar[kategori] = liste;
    }
    final digerleri = urunler.where((u) => !KantinUrunu.kategoriSirasi.contains(u.kategori)).toList();
    if (digerleri.isNotEmpty) gruplar['Diger'] = digerleri;
    return gruplar;
  }
}

class YemekhaneBinasi {
  final int id;
  final String ad;

  const YemekhaneBinasi({required this.id, required this.ad});

  factory YemekhaneBinasi.fromJson(Map<String, dynamic> json) {
    return YemekhaneBinasi(id: json['id'] as int, ad: json['ad'] as String? ?? 'Yemekhane');
  }
}
