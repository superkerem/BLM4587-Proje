import '../core/constants/api_constants.dart';
import '../models/yemekhane.dart';
import 'oturum_servisi.dart';

class YemekhaneServisi {
  YemekhaneServisi._();

  static String tarihMetni(DateTime gun) =>
      '${gun.year}-${gun.month.toString().padLeft(2, '0')}-${gun.day.toString().padLeft(2, '0')}';

  // Verilen günün içinde olduğu haftanın (pazartesi-cuma) menüleri.
  static Future<List<YemekMenusu>> haftalik(DateTime gun) async {
    final liste = await OturumServisi.ornek.api.get('${ApiSabitleri.yemekhaneHaftalik}?tarih=${tarihMetni(gun)}')
        as List<dynamic>;
    return liste.map((e) => YemekMenusu.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<List<Kantin>> kantinler() async {
    final liste = await OturumServisi.ornek.api.get(ApiSabitleri.kantinler) as List<dynamic>;
    return liste.map((e) => Kantin.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<List<YemekhaneBinasi>> binalar() async {
    final liste = await OturumServisi.ornek.api.get(ApiSabitleri.yemekhaneBinalari) as List<dynamic>;
    return liste.map((e) => YemekhaneBinasi.fromJson(e as Map<String, dynamic>)).toList();
  }
}
