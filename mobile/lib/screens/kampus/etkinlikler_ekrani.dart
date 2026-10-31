import 'package:flutter/material.dart';

import '../../core/moduller.dart';
import '../../widgets/modul_iskeleti.dart';

class EtkinliklerEkrani extends StatelessWidget {
  const EtkinliklerEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    final modul = Moduller.etkinlikler;
    return ModulIskeleti(baslik: modul.baslik, ikon: modul.ikon, aciklama: modul.aciklama);
  }
}
