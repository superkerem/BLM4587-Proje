import 'package:flutter/material.dart';

import '../../core/moduller.dart';
import '../../widgets/modul_iskeleti.dart';

class DerslikBulEkrani extends StatelessWidget {
  const DerslikBulEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    final modul = Moduller.derslikBul;
    return ModulIskeleti(baslik: modul.baslik, ikon: modul.ikon, aciklama: modul.aciklama);
  }
}
