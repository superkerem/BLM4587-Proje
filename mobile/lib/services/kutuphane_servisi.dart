import '../core/constants/api_constants.dart';
import '../core/kutuphane_kurallari.dart';
import '../core/turkiye_saati.dart';
import '../models/kutuphane.dart';
import 'oturum_servisi.dart';

class KutuphaneServisi {
  KutuphaneServisi._();

  static Future<KutuphaneDolulugu> doluluk() async {
    final json = await OturumServisi.ornek.api.get(ApiSabitleri.kutuphaneDoluluk);
    return KutuphaneDolulugu.fromJson(json as Map<String, dynamic>);
  }

  static Future<List<KutuphaneMasasi>> masalar({
    required DateTime gun,
    required int baslangic,
    required int sureDakika,
  }) async {
    final yol = '${ApiSabitleri.kutuphaneMasalar}?tarih=${KutuphaneKurallari.tarihMetni(gun)}'
        '&baslangic=${TurkiyeSaati.saatMetni(baslangic)}&sure=$sureDakika';
    final liste = await OturumServisi.ornek.api.get(yol) as List<dynamic>;
    return liste.map((e) => KutuphaneMasasi.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<List<Rezervasyon>> rezervasyonlarim() async {
    final liste = await OturumServisi.ornek.api.get(ApiSabitleri.rezervasyonlarim) as List<dynamic>;
    return liste.map((e) => Rezervasyon.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<Rezervasyon> rezervasyonYap({
    required int masaId,
    required DateTime gun,
    required int baslangic,
    required int sureDakika,
  }) async {
    final json = await OturumServisi.ornek.api.post(ApiSabitleri.rezervasyonlar, {
      'masaId': masaId,
      'tarih': KutuphaneKurallari.tarihMetni(gun),
      'baslangic': TurkiyeSaati.saatMetni(baslangic),
      'sureDakika': sureDakika,
    });
    return Rezervasyon.fromJson(json as Map<String, dynamic>);
  }

  static Future<void> iptalEt(int id) async {
    await OturumServisi.ornek.api.delete('${ApiSabitleri.rezervasyonlar}/$id');
  }

  static Future<void> bosalt(int id) async {
    await OturumServisi.ornek.api.post('${ApiSabitleri.rezervasyonlar}/$id/bosalt', {});
  }
}
