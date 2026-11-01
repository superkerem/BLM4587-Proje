class Duyuru {
  final int id;
  final String baslik;
  final String icerik;
  final bool onemliMi;
  final DateTime yayinTarihi;
  final String yazarAdi;

  const Duyuru({
    required this.id,
    required this.baslik,
    required this.icerik,
    required this.onemliMi,
    required this.yayinTarihi,
    required this.yazarAdi,
  });

  factory Duyuru.fromJson(Map<String, dynamic> json) {
    return Duyuru(
      id: json['id'] as int,
      baslik: json['baslik'] as String? ?? '',
      icerik: json['icerik'] as String? ?? '',
      onemliMi: json['onemliMi'] as bool? ?? false,
      yayinTarihi: DateTime.tryParse(json['yayinTarihi'] as String? ?? '')?.toLocal() ?? DateTime.now(),
      yazarAdi: json['yazarAdi'] as String? ?? 'Yönetim',
    );
  }
}
