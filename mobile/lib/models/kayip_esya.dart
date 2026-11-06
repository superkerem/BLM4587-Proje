class KayipEsya {
  final int id;
  final String baslik;
  final String aciklama;
  final String bulunanYer;
  final DateTime bulunmaTarihi;
  final bool teslimEdildiMi;
  final int bildirenId;
  final String bildirenAdi;

  const KayipEsya({
    required this.id,
    required this.baslik,
    required this.aciklama,
    required this.bulunanYer,
    required this.bulunmaTarihi,
    required this.teslimEdildiMi,
    required this.bildirenId,
    required this.bildirenAdi,
  });

  // Örn. 05.11.2026
  String get tarihMetni => tarihYaz(bulunmaTarihi);

  static String tarihYaz(DateTime t) =>
      '${t.day.toString().padLeft(2, '0')}.${t.month.toString().padLeft(2, '0')}.${t.year}';

  factory KayipEsya.fromJson(Map<String, dynamic> json) {
    // API tarihi UTC gece yarısı olarak saklar; gün kaymasın diye sadece tarih kısmı alınır.
    final tarih = DateTime.tryParse(json['bulunmaTarihi'] as String? ?? '');
    return KayipEsya(
      id: json['id'] as int,
      baslik: json['baslik'] as String? ?? '',
      aciklama: json['aciklama'] as String? ?? '',
      bulunanYer: json['bulunanYer'] as String? ?? '',
      bulunmaTarihi: tarih != null ? DateTime(tarih.year, tarih.month, tarih.day) : DateTime.now(),
      teslimEdildiMi: json['teslimEdildiMi'] as bool? ?? false,
      bildirenId: json['bildirenId'] as int? ?? 0,
      bildirenAdi: json['bildirenAdi'] as String? ?? '',
    );
  }
}
