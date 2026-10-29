import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/constants/api_constants.dart';

// API'nin döndürdüğü { mesaj, hatalar } biçimindeki hata.
class ApiHatasi implements Exception {
  final int durumKodu;
  final String mesaj;
  final Map<String, String> alanHatalari;

  const ApiHatasi(this.durumKodu, this.mesaj, [this.alanHatalari = const {}]);

  bool get yetkisiz => durumKodu == 401;
  bool get erisimEngellendi => durumKodu == 403;

  @override
  String toString() => mesaj;
}

class ApiIstemcisi {
  ApiIstemcisi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  // Oturum servisi token'ı buraya verir; her istekte Authorization başlığına eklenir.
  String? token;

  // 401 gelince (token süresi doldu vb.) oturum servisi bilgilendirilir.
  void Function()? oturumSonlandi;

  Future<dynamic> get(String yol) => _gonder('GET', yol);

  Future<dynamic> post(String yol, Map<String, dynamic> govde) => _gonder('POST', yol, govde);

  Future<dynamic> _gonder(String metot, String yol, [Map<String, dynamic>? govde]) async {
    final uri = Uri.parse('${ApiSabitleri.baseUrl}$yol');
    final basliklar = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final http.Response yanit;
    try {
      final istek = metot == 'POST'
          ? _client.post(uri, headers: basliklar, body: jsonEncode(govde))
          : _client.get(uri, headers: basliklar);
      yanit = await istek.timeout(ApiSabitleri.zamanAsimi);
    } on TimeoutException {
      throw const ApiHatasi(0, 'Sunucu yanıt vermedi. Lütfen tekrar deneyin.');
    } on http.ClientException {
      throw ApiHatasi(0, 'Sunucuya bağlanılamadı (${ApiSabitleri.baseUrl}). API çalışıyor mu?');
    }

    final icerik = yanit.body.isEmpty ? null : _jsonCoz(yanit.body);

    if (yanit.statusCode >= 200 && yanit.statusCode < 300) {
      return icerik;
    }

    if (yanit.statusCode == 401 && token != null) {
      oturumSonlandi?.call();
    }

    throw _hataOlustur(yanit.statusCode, icerik);
  }

  dynamic _jsonCoz(String metin) {
    try {
      return jsonDecode(metin);
    } on FormatException {
      return null;
    }
  }

  ApiHatasi _hataOlustur(int durumKodu, dynamic icerik) {
    var mesaj = 'Beklenmeyen bir hata oluştu ($durumKodu).';
    final alanHatalari = <String, String>{};

    if (icerik is Map<String, dynamic>) {
      mesaj = icerik['mesaj'] as String? ?? mesaj;
      final hatalar = icerik['hatalar'];
      if (hatalar is Map<String, dynamic>) {
        hatalar.forEach((alan, liste) {
          if (liste is List && liste.isNotEmpty) {
            alanHatalari[alan.toLowerCase()] = liste.join('\n');
          }
        });
      }
    }

    return ApiHatasi(durumKodu, mesaj, alanHatalari);
  }
}
