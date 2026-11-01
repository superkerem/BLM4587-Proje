import 'package:flutter/material.dart';

import '../widgets/panel_ogeleri.dart';

class ErisimEngellendiEkrani extends StatelessWidget {
  const ErisimEngellendiEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Erişim Engellendi')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          BosDurum(
            ikon: Icons.shield_outlined,
            baslik: 'Erişim Engellendi',
            aciklama: 'Bu sayfayı görüntülemek için yetkiniz bulunmuyor.',
            dugmeMetni: 'Ana Sayfaya Dön',
            dugmeyeBasilinca: () => Navigator.of(context).popUntil((route) => route.isFirst),
          ),
        ],
      ),
    );
  }
}
