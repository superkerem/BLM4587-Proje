import 'package:flutter/material.dart';

import '../../core/moduller.dart';
import '../../core/tema.dart';
import '../../models/kayip_esya.dart';
import '../../services/kayip_esya_servisi.dart';
import '../../widgets/panel_ogeleri.dart';

class KayipEsyaEkrani extends StatefulWidget {
  const KayipEsyaEkrani({super.key});

  @override
  State<KayipEsyaEkrani> createState() => _KayipEsyaEkraniState();
}

class _KayipEsyaEkraniState extends State<KayipEsyaEkrani> {
  bool _sadeceBekleyenler = false;
  late Future<List<KayipEsya>> _ilanlar = KayipEsyaServisi.listele();

  Future<void> _yenile() async {
    final yeni = KayipEsyaServisi.listele(sadeceBekleyenler: _sadeceBekleyenler);
    setState(() {
      _ilanlar = yeni;
    });
    try {
      await yeni;
    } catch (_) {
      // Hata FutureBuilder içinde gösterilir.
    }
  }

  void _filtreDegisti(bool sadeceBekleyenler) {
    _sadeceBekleyenler = sadeceBekleyenler;
    _yenile();
  }

  Future<void> _detayaGit(KayipEsya esya) async {
    final degisti = await Navigator.pushNamed(context, '/kampus/kayip-esya/detay', arguments: esya);
    if (degisti == true) _yenile();
  }

  Future<void> _ilanEkle() async {
    final eklenen = await Navigator.pushNamed(context, '/kampus/kayip-esya/form');
    if (eklenen != null) _yenile();
  }

  @override
  Widget build(BuildContext context) {
    final modul = Moduller.kayipEsya;
    return Scaffold(
      appBar: AppBar(title: Text(modul.baslik)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _ilanEkle,
        icon: const Icon(Icons.add),
        label: const Text('İlan Ekle'),
      ),
      body: RefreshIndicator(
        onRefresh: _yenile,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
          children: [
            SayfaBasligi(baslik: 'Kayıp Eşya Panosu', aciklama: modul.aciklama),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('Tümü'), icon: Icon(Icons.list)),
                ButtonSegment(value: true, label: Text('Bekleyenler'), icon: Icon(Icons.hourglass_empty)),
              ],
              selected: {_sadeceBekleyenler},
              onSelectionChanged: (secim) => _filtreDegisti(secim.first),
            ),
            const SizedBox(height: 16),
            _ilanListesi(),
          ],
        ),
      ),
    );
  }

  Widget _ilanListesi() {
    return FutureBuilder<List<KayipEsya>>(
      future: _ilanlar,
      builder: (context, durum) {
        if (durum.connectionState != ConnectionState.done) {
          return const PanelKart(child: Center(child: CircularProgressIndicator()));
        }

        if (durum.hasError) {
          return BosDurum(
            ikon: Icons.cloud_off,
            baslik: 'İlanlar yüklenemedi',
            aciklama: durum.error.toString(),
            dugmeMetni: 'Tekrar Dene',
            dugmeyeBasilinca: _yenile,
          );
        }

        final ilanlar = durum.data!;
        if (ilanlar.isEmpty) {
          return BosDurum(
            ikon: Icons.search_off,
            baslik: _sadeceBekleyenler ? 'Bekleyen ilan yok' : 'Henüz ilan yok',
            aciklama: 'Bulduğunuz bir eşyayı "İlan Ekle" düğmesiyle bildirebilirsiniz.',
          );
        }

        return Column(
          children: [for (final esya in ilanlar) _IlanKarti(esya: esya, onTap: () => _detayaGit(esya))],
        );
      },
    );
  }
}

class _IlanKarti extends StatelessWidget {
  const _IlanKarti({required this.esya, required this.onTap});

  final KayipEsya esya;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Tema.kose),
        child: PanelKart(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            esya.baslik,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Renkler.yazi),
                          ),
                        ),
                        if (esya.teslimEdildiMi) ...[
                          const SizedBox(width: 8),
                          const Rozet(metin: 'Teslim edildi', arkaPlan: Renkler.vurguAcik, yaziRengi: Renkler.vurgu),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    _BilgiSatiri(ikon: Icons.place_outlined, metin: esya.bulunanYer),
                    const SizedBox(height: 4),
                    _BilgiSatiri(ikon: Icons.event_outlined, metin: esya.tarihMetni),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Renkler.yaziSoluk),
            ],
          ),
        ),
      ),
    );
  }
}

class _BilgiSatiri extends StatelessWidget {
  const _BilgiSatiri({required this.ikon, required this.metin});

  final IconData ikon;
  final String metin;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(ikon, size: 16, color: Renkler.yaziSoluk),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            metin,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Renkler.yaziSoluk),
          ),
        ),
      ],
    );
  }
}
