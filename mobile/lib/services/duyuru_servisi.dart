import '../core/constants/api_constants.dart';
import '../models/duyuru.dart';
import 'oturum_servisi.dart';

class DuyuruServisi {
  DuyuruServisi._();

  static Future<List<Duyuru>> listele({int adet = 10}) async {
    final liste = await OturumServisi.ornek.api.get('${ApiSabitleri.duyurular}?adet=$adet') as List<dynamic>;
    return liste.map((e) => Duyuru.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<Duyuru> getir(int id) async {
    final json = await OturumServisi.ornek.api.get('${ApiSabitleri.duyurular}/$id');
    return Duyuru.fromJson(json as Map<String, dynamic>);
  }

  // Ekleme, güncelleme ve silme sadece Yönetici'ye açık; diğer kullanıcılara API 403 döner.
  static Future<Duyuru> ekle(Map<String, dynamic> bilgiler) async {
    final json = await OturumServisi.ornek.api.post(ApiSabitleri.duyurular, bilgiler);
    return Duyuru.fromJson(json as Map<String, dynamic>);
  }

  static Future<Duyuru> guncelle(int id, Map<String, dynamic> bilgiler) async {
    final json = await OturumServisi.ornek.api.put('${ApiSabitleri.duyurular}/$id', bilgiler);
    return Duyuru.fromJson(json as Map<String, dynamic>);
  }

  static Future<void> sil(int id) async {
    await OturumServisi.ornek.api.delete('${ApiSabitleri.duyurular}/$id');
  }

  // Form verisini API'nin beklediği DuyuruIstegi gövdesine çevirir.
  static Map<String, dynamic> govdeOlustur({
    required String baslik,
    required String icerik,
    required bool onemliMi,
  }) {
    return {
      'baslik': baslik.trim(),
      'icerik': icerik.trim(),
      'onemliMi': onemliMi,
    };
  }
}
