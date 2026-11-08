import '../core/constants/api_constants.dart';
import '../models/ders_programi.dart';
import '../models/mekan.dart';
import 'oturum_servisi.dart';

class KampusServisi {
  KampusServisi._();

  static Future<List<Mekan>>? _mekanlar;
  static Future<DersProgrami>? _program;

  static Future<List<Mekan>> mekanlar() => _mekanlar ??= _mekanlariGetir();

  static Future<DersProgrami> dersProgrami() => _program ??= _programiGetir();

  static Future<List<Mekan>> _mekanlariGetir() async {
    try {
      final liste = await OturumServisi.ornek.api.get(ApiSabitleri.mekanlar) as List<dynamic>;
      return liste.map((e) => Mekan.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      _mekanlar = null;
      rethrow;
    }
  }

  static Future<DersProgrami> _programiGetir() async {
    try {
      final json = await OturumServisi.ornek.api.get(ApiSabitleri.dersProgrami);
      return DersProgrami.fromJson(json as Map<String, dynamic>);
    } catch (_) {
      _program = null;
      rethrow;
    }
  }

  static Future<Set<String>> derslerim() async {
    final liste = await OturumServisi.ornek.api.get(ApiSabitleri.derslerim) as List<dynamic>;
    return liste.cast<String>().toSet();
  }

  static Future<Set<String>> derslerimiKaydet(Set<String> kodlar) async {
    final liste = await OturumServisi.ornek.api.put(ApiSabitleri.derslerim, {'kodlar': kodlar.toList()})
        as List<dynamic>;
    return liste.cast<String>().toSet();
  }

  static Future<List<Sinav>> sinavlarim() async {
    final liste = await OturumServisi.ornek.api.get(ApiSabitleri.sinavlarim) as List<dynamic>;
    return liste.map((e) => Sinav.fromJson(e as Map<String, dynamic>)).toList();
  }
}
