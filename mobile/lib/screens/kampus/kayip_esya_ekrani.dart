import 'package:flutter/material.dart';

import '../../core/moduller.dart';
import '../../widgets/modul_iskeleti.dart';

class KayipEsyaEkrani extends StatelessWidget {
  const KayipEsyaEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    final modul = Moduller.kayipEsya;
    return ModulIskeleti(baslik: modul.baslik, ikon: modul.ikon, aciklama: modul.aciklama);
  }
}
