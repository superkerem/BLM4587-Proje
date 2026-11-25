import 'package:flutter/material.dart';

import '../core/tema.dart';
import '../models/sinav.dart';
import 'panel_ogeleri.dart';

class SinavSatiri extends StatelessWidget {
  const SinavSatiri({
    super.key,
    required this.sinav,
    this.onTap,
    this.haritaGosterilsin = true,
    this.sonEk,
  });

  final Sinav sinav;
  final VoidCallback? onTap;
  final bool haritaGosterilsin;
  final Widget? sonEk;

  @override
  Widget build(BuildContext context) {
    final mekanId = sinav.mekanId;
    final mekanMetni = sinav.mekanMetni;
    final soluk = sinav.tamamlandiMi;

    final icerik = Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TarihKutusu(tarih: sinav.tarih, soluk: soluk),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Rozet(
                      metin: sinav.tur.etiket,
                      arkaPlan: soluk ? Renkler.arka : Renkler.vurgu,
                      yaziRengi: soluk ? Renkler.yaziSoluk : Colors.white,
                    ),
                    if (soluk) const Rozet.kullanici(metin: 'Tamamlandı'),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  sinav.dersAdi.isEmpty || sinav.dersAdi == sinav.dersKodu
                      ? sinav.dersKodu
                      : '${sinav.dersKodu} · ${sinav.dersAdi}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: soluk ? Renkler.yaziSoluk : Renkler.yazi,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${TurkceTarih.uzun(sinav.tarih)} · ${sinav.saatAraligi}',
                  style: TextStyle(fontSize: 13, color: soluk ? Renkler.yaziSoluk : Renkler.yazi),
                ),
                const SizedBox(height: 2),
                Text(
                  mekanMetni == null ? sinav.derslikMetni : '${sinav.derslikMetni} · $mekanMetni',
                  style: const TextStyle(fontSize: 13, color: Renkler.yaziSoluk),
                ),
              ],
            ),
          ),
          if (haritaGosterilsin && mekanId != null)
            IconButton(
              tooltip: 'Haritada göster',
              icon: const Icon(Icons.map_outlined, color: Renkler.vurgu),
              onPressed: () => Navigator.pushNamed(context, '/kampus/harita', arguments: mekanId),
            ),
          if (sonEk != null) sonEk!,
        ],
      ),
    );

    final govde = Opacity(opacity: soluk ? 0.7 : 1, child: icerik);
    return onTap == null ? govde : InkWell(onTap: onTap, child: govde);
  }
}

class _TarihKutusu extends StatelessWidget {
  const _TarihKutusu({required this.tarih, required this.soluk});

  final DateTime tarih;
  final bool soluk;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: soluk ? Renkler.arka : Renkler.vurguAcik,
        borderRadius: BorderRadius.circular(Tema.kose),
      ),
      child: Column(
        children: [
          Text(
            '${tarih.day}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              height: 1.1,
              color: soluk ? Renkler.yaziSoluk : Renkler.vurgu,
            ),
          ),
          Text(
            TurkceTarih.kisaAy(tarih),
            style: TextStyle(fontSize: 12, color: soluk ? Renkler.yaziSoluk : Renkler.vurgu),
          ),
        ],
      ),
    );
  }
}
