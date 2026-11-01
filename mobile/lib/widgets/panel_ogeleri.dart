import 'package:flutter/material.dart';

import '../core/tema.dart';

class PanelKart extends StatelessWidget {
  const PanelKart({super.key, required this.child, this.padding = const EdgeInsets.all(20)});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(padding: padding, child: child),
    );
  }
}

class BosDurum extends StatelessWidget {
  const BosDurum({
    super.key,
    required this.ikon,
    required this.baslik,
    required this.aciklama,
    this.dugmeMetni,
    this.dugmeyeBasilinca,
  });

  final IconData ikon;
  final String baslik;
  final String aciklama;
  final String? dugmeMetni;
  final VoidCallback? dugmeyeBasilinca;

  @override
  Widget build(BuildContext context) {
    return PanelKart(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            Icon(ikon, size: 32, color: Renkler.vurgu),
            const SizedBox(height: 12),
            Text(
              baslik,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Renkler.yazi),
            ),
            const SizedBox(height: 6),
            Text(aciklama, textAlign: TextAlign.center, style: const TextStyle(color: Renkler.yaziSoluk)),
            if (dugmeMetni != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(onPressed: dugmeyeBasilinca, child: Text(dugmeMetni!)),
            ],
          ],
        ),
      ),
    );
  }
}

class BolumBasligi extends StatelessWidget {
  const BolumBasligi(this.metin, {super.key});

  final String metin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        metin,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Renkler.yazi),
      ),
    );
  }
}

class Rozet extends StatelessWidget {
  const Rozet({super.key, required this.metin, required this.arkaPlan, required this.yaziRengi});

  const Rozet.yonetici({super.key, this.metin = 'Yonetici'})
      : arkaPlan = Renkler.vurguAcik,
        yaziRengi = Renkler.vurgu;

  const Rozet.kullanici({super.key, this.metin = 'Kullanici'})
      : arkaPlan = Renkler.arka,
        yaziRengi = Renkler.yaziSoluk;

  const Rozet.onemli({super.key, this.metin = 'Önemli'})
      : arkaPlan = Renkler.vurgu,
        yaziRengi = Colors.white;

  final String metin;
  final Color arkaPlan;
  final Color yaziRengi;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: arkaPlan, borderRadius: BorderRadius.circular(6)),
      child: Text(metin, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: yaziRengi)),
    );
  }
}

class SayfaBasligi extends StatelessWidget {
  const SayfaBasligi({super.key, required this.baslik, this.aciklama});

  final String baslik;
  final String? aciklama;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(baslik, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Renkler.yazi)),
          if (aciklama != null) ...[
            const SizedBox(height: 4),
            Text(aciklama!, style: const TextStyle(color: Renkler.yaziSoluk)),
          ],
        ],
      ),
    );
  }
}
