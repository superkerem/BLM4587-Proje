import '../core/roller.dart';

class Kullanici {
  final int id;
  final String ad;
  final String soyad;
  final String? email;
  final String? ogrenciNo;
  final List<String> roller;
  final DateTime kayitTarihi;

  const Kullanici({
    required this.id,
    required this.ad,
    required this.soyad,
    required this.email,
    required this.ogrenciNo,
    required this.roller,
    required this.kayitTarihi,
  });

  String get adSoyad => '$ad $soyad';
  bool get yoneticiMi => roller.contains(Roller.yonetici);

  factory Kullanici.fromJson(Map<String, dynamic> json) {
    return Kullanici(
      id: json['id'] as int,
      ad: json['ad'] as String? ?? '',
      soyad: json['soyad'] as String? ?? '',
      email: json['email'] as String?,
      ogrenciNo: json['ogrenciNo'] as String?,
      roller: (json['roller'] as List<dynamic>? ?? []).cast<String>(),
      kayitTarihi: DateTime.tryParse(json['kayitTarihi'] as String? ?? '')?.toLocal() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'ad': ad,
        'soyad': soyad,
        'email': email,
        'ogrenciNo': ogrenciNo,
        'roller': roller,
        'kayitTarihi': kayitTarihi.toUtc().toIso8601String(),
      };
}
