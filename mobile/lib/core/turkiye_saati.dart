class TurkiyeSaati {
  TurkiyeSaati._();

  static DateTime simdi() => DateTime.now().toUtc().add(const Duration(hours: 3));

  static int dakika(DateTime zaman) => zaman.hour * 60 + zaman.minute;

  static int dakikayaCevir(String saat) {
    final parcalar = saat.split(':');
    return int.parse(parcalar[0]) * 60 + int.parse(parcalar[1]);
  }

  static String saatMetni(int dakika) =>
      '${(dakika ~/ 60).toString().padLeft(2, '0')}:${(dakika % 60).toString().padLeft(2, '0')}';

  static const kisaGunler = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
}
