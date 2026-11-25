import '../core/constants/api_constants.dart';
import '../core/turkiye_saati.dart';
import '../models/sinav.dart';
import 'oturum_servisi.dart';

class SinavServisi {
  SinavServisi._();

  static Future<List<Sinav>> dersSinavlari(Set<String> dersKodlari) async {
    if (dersKodlari.isEmpty) return [];
    final kodlar = Uri.encodeQueryComponent((dersKodlari.toList()..sort()).join(','));
    final liste = await OturumServisi.ornek.api.get('${ApiSabitleri.sinavlar}?dersKodlari=$kodlar') as List<dynamic>;
    return liste.map((e) => Sinav.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<YonetimSinavlari> yonetimListele() async {
    final json = await OturumServisi.ornek.api.get(ApiSabitleri.yonetimSinavlar);
    return YonetimSinavlari.fromJson(json as Map<String, dynamic>);
  }

  static Future<SinavDetayi> getir(int id) async {
    final json = await OturumServisi.ornek.api.get('${ApiSabitleri.yonetimSinavlar}/$id');
    return SinavDetayi.fromJson(json as Map<String, dynamic>);
  }

  static Future<SinavDetayi> ekle(Map<String, dynamic> govde) async {
    final json = await OturumServisi.ornek.api.post(ApiSabitleri.yonetimSinavlar, govde);
    return SinavDetayi.fromJson(json as Map<String, dynamic>);
  }

  static Future<SinavDetayi> guncelle(int id, Map<String, dynamic> govde) async {
    final json = await OturumServisi.ornek.api.put('${ApiSabitleri.yonetimSinavlar}/$id', govde);
    return SinavDetayi.fromJson(json as Map<String, dynamic>);
  }

  static Future<void> sil(int id) async {
    await OturumServisi.ornek.api.delete('${ApiSabitleri.yonetimSinavlar}/$id');
  }

  static Map<String, dynamic> govdeOlustur({
    required String? dersKodu,
    required SinavTuru? tur,
    required DateTime? tarih,
    required int? baslangic,
    required int? bitis,
    required Set<int> derslikIdleri,
  }) {
    return {
      'dersKodu': dersKodu ?? '',
      'tur': tur?.apiDegeri ?? '',
      'tarih': tarih == null ? '' : sinavTarihMetni(tarih),
      'baslangic': baslangic == null ? '' : TurkiyeSaati.saatMetni(baslangic),
      'bitis': bitis == null ? '' : TurkiyeSaati.saatMetni(bitis),
      'derslikIdleri': derslikIdleri.toList()..sort(),
    };
  }
}
