import '../core/constants/api_constants.dart';
import '../models/kayip_esya.dart';
import 'oturum_servisi.dart';

class KayipEsyaServisi {
  KayipEsyaServisi._();

  static Future<List<KayipEsya>> listele({bool sadeceBekleyenler = false}) async {
    final yol = sadeceBekleyenler ? '${ApiSabitleri.kayipEsyalar}?teslimEdilmemis=true' : ApiSabitleri.kayipEsyalar;
    final liste = await OturumServisi.ornek.api.get(yol) as List<dynamic>;
    return liste.map((e) => KayipEsya.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<KayipEsya> getir(int id) async {
    final json = await OturumServisi.ornek.api.get('${ApiSabitleri.kayipEsyalar}/$id');
    return KayipEsya.fromJson(json as Map<String, dynamic>);
  }

  static Future<KayipEsya> ekle(Map<String, dynamic> bilgiler) async {
    final json = await OturumServisi.ornek.api.post(ApiSabitleri.kayipEsyalar, bilgiler);
    return KayipEsya.fromJson(json as Map<String, dynamic>);
  }

  static Future<KayipEsya> guncelle(int id, Map<String, dynamic> bilgiler) async {
    final json = await OturumServisi.ornek.api.put('${ApiSabitleri.kayipEsyalar}/$id', bilgiler);
    return KayipEsya.fromJson(json as Map<String, dynamic>);
  }

  static Future<void> sil(int id) async {
    await OturumServisi.ornek.api.delete('${ApiSabitleri.kayipEsyalar}/$id');
  }

  // Form verisini API'nin beklediği gövdeye çevirir; tarih saatsiz (yyyy-MM-dd) gönderilir.
  static Map<String, dynamic> govdeOlustur({
    required String baslik,
    required String aciklama,
    required String bulunanYer,
    required DateTime bulunmaTarihi,
    required bool teslimEdildiMi,
  }) {
    final ay = bulunmaTarihi.month.toString().padLeft(2, '0');
    final gun = bulunmaTarihi.day.toString().padLeft(2, '0');
    return {
      'baslik': baslik.trim(),
      'aciklama': aciklama.trim(),
      'bulunanYer': bulunanYer.trim(),
      'bulunmaTarihi': '${bulunmaTarihi.year}-$ay-$gun',
      'teslimEdildiMi': teslimEdildiMi,
    };
  }
}
