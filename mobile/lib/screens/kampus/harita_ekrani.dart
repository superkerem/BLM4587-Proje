import 'package:flutter/material.dart';

import '../../core/moduller.dart';
import '../../widgets/modul_iskeleti.dart';

class HaritaEkrani extends StatelessWidget {
  const HaritaEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    final modul = Moduller.harita;
    return ModulIskeleti(baslik: modul.baslik, ikon: modul.ikon, aciklama: modul.aciklama);
  }
}
