import 'package:flutter/material.dart';

import '../core/tema.dart';
import 'panel_ogeleri.dart';

class ModulIskeleti extends StatelessWidget {
  const ModulIskeleti({
    super.key,
    required this.baslik,
    required this.ikon,
    required this.aciklama,
  });

  final String baslik;
  final IconData ikon;
  final String aciklama;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(baslik)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Renkler.vurgu, borderRadius: BorderRadius.circular(Tema.kose)),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(Tema.kose)),
                  child: Icon(ikon, color: Renkler.vurgu),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        baslik,
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(aciklama, style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          BosDurum(
            ikon: ikon,
            baslik: 'Bu modül hazırlanıyor',
            aciklama: 'İçerik sonraki haftalarda eklenecek.',
            dugmeMetni: 'Ana Sayfaya Dön',
            dugmeyeBasilinca: () => Navigator.of(context).popUntil((route) => route.isFirst),
          ),
        ],
      ),
    );
  }
}
