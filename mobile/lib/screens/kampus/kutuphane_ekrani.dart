import 'package:flutter/material.dart';

import '../../core/moduller.dart';
import '../../widgets/modul_iskeleti.dart';

class KutuphaneEkrani extends StatelessWidget {
  const KutuphaneEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    final modul = Moduller.kutuphane;
    return ModulIskeleti(baslik: modul.baslik, ikon: modul.ikon, aciklama: modul.aciklama);
  }
}
