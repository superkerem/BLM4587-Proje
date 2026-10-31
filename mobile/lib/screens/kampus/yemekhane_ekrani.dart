import 'package:flutter/material.dart';

import '../../core/moduller.dart';
import '../../widgets/modul_iskeleti.dart';

class YemekhaneEkrani extends StatelessWidget {
  const YemekhaneEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    final modul = Moduller.yemekhane;
    return ModulIskeleti(baslik: modul.baslik, ikon: modul.ikon, aciklama: modul.aciklama);
  }
}
