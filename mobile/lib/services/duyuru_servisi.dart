import '../core/constants/api_constants.dart';
import '../models/duyuru.dart';
import 'oturum_servisi.dart';

class DuyuruServisi {
  DuyuruServisi._();

  static Future<List<Duyuru>> listele({int adet = 10}) async {
    final liste = await OturumServisi.ornek.api.get('${ApiSabitleri.duyurular}?adet=$adet') as List<dynamic>;
    return liste.map((e) => Duyuru.fromJson(e as Map<String, dynamic>)).toList();
  }
}
