import 'turkiye_saati.dart';

class KutuphaneKurallari {
  KutuphaneKurallari._();

  static const acilisDakikasi = 8 * 60;
  static const kapanisDakikasi = 22 * 60;
  static const adimDakika = 30;
  static const enKisaSureDakika = 30;
  static const enUzunSureDakika = 180;
  static const gunlukToplamDakika = 300;
  static const ileriGunSayisi = 7;

  static DateTime bugun(DateTime simdi) => DateTime(simdi.year, simdi.month, simdi.day);

  static List<DateTime> secilebilirGunler(DateTime simdi) {
    final ilk = bugun(simdi);
    return [
      for (var i = 0; i <= ileriGunSayisi; i++) DateTime(ilk.year, ilk.month, ilk.day + i),
    ].where((gun) => baslangicSecenekleri(gun, simdi).isNotEmpty).toList();
  }

  static bool ayniGunMu(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  static List<int> baslangicSecenekleri(DateTime gun, DateTime simdi) {
    var ilk = acilisDakikasi;
    if (ayniGunMu(gun, simdi)) {
      final dakika = TurkiyeSaati.dakika(simdi);
      final dilim = dakika - dakika % adimDakika;
      if (dilim > ilk) ilk = dilim;
    }
    return [
      for (var dakika = ilk; dakika + enKisaSureDakika <= kapanisDakikasi; dakika += adimDakika) dakika,
    ];
  }

  static List<int> sureSecenekleri(int baslangic, {int kalanGunlukDakika = gunlukToplamDakika}) {
    final enFazla = [enUzunSureDakika, kapanisDakikasi - baslangic, kalanGunlukDakika].reduce((a, b) => a < b ? a : b);
    return [
      for (var sure = enKisaSureDakika; sure <= enFazla; sure += adimDakika) sure,
    ];
  }

  static String sureMetni(int dakika) {
    final saat = dakika ~/ 60;
    final kalan = dakika % 60;
    if (saat == 0) return '$kalan dk';
    if (kalan == 0) return '$saat sa';
    return '$saat sa $kalan dk';
  }

  static String tarihMetni(DateTime gun) =>
      '${gun.year}-${gun.month.toString().padLeft(2, '0')}-${gun.day.toString().padLeft(2, '0')}';
}
