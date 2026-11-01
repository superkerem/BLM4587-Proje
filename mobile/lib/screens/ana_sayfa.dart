import 'package:flutter/material.dart';

import '../core/moduller.dart';
import '../core/tema.dart';
import '../models/duyuru.dart';
import '../services/duyuru_servisi.dart';
import '../services/oturum_servisi.dart';
import '../widgets/panel_ogeleri.dart';
import '../widgets/yan_menu.dart';

class AnaSayfa extends StatefulWidget {
  const AnaSayfa({super.key});

  @override
  State<AnaSayfa> createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  late Future<List<Duyuru>> _duyurular = DuyuruServisi.listele();

  Future<void> _yenile() async {
    final yeni = DuyuruServisi.listele();
    setState(() => _duyurular = yeni);
    await yeni.catchError((_) => <Duyuru>[]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AÜ Hub')),
      drawer: const YanMenu(aktifRota: '/'),
      body: RefreshIndicator(
        onRefresh: _yenile,
        child: LayoutBuilder(
          builder: (context, kisitlar) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              ListenableBuilder(
                listenable: OturumServisi.ornek,
                builder: (context, _) => _Karsilama(
                  ad: OturumServisi.ornek.kullanici?.ad ?? '',
                  logoGoster: kisitlar.maxWidth >= 600,
                ),
              ),
              const SizedBox(height: 28),
              const BolumBasligi('Kampüs Modülleri'),
              _ModulKartlari(genislik: kisitlar.maxWidth - 32),
              const SizedBox(height: 28),
              const BolumBasligi('Duyurular'),
              _duyuruBolumu(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _duyuruBolumu() {
    return FutureBuilder<List<Duyuru>>(
      future: _duyurular,
      builder: (context, durum) {
        if (durum.connectionState != ConnectionState.done) {
          return const PanelKart(child: Center(child: CircularProgressIndicator()));
        }

        if (durum.hasError) {
          return BosDurum(
            ikon: Icons.cloud_off,
            baslik: 'Duyurular yüklenemedi',
            aciklama: durum.error.toString(),
            dugmeMetni: 'Tekrar Dene',
            dugmeyeBasilinca: _yenile,
          );
        }

        final duyurular = durum.data!;
        if (duyurular.isEmpty) {
          return const BosDurum(
            ikon: Icons.campaign_outlined,
            baslik: 'Henüz duyuru yok',
            aciklama: 'Yöneticiler tarafından paylaşılan duyurular burada görünecek.',
          );
        }

        return PanelKart(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < duyurular.length; i++) ...[
                if (i > 0) const Divider(),
                _DuyuruSatiri(duyuru: duyurular[i]),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _Karsilama extends StatelessWidget {
  const _Karsilama({required this.ad, required this.logoGoster});

  final String ad;
  final bool logoGoster;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Renkler.vurgu, borderRadius: BorderRadius.circular(Tema.kose)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(TurkceTarih.uzun(DateTime.now()), style: const TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 6),
                Text(
                  'Hoş geldin, $ad',
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Ankara Üniversitesi Kampüs Portalı'na hoş geldin. Kampüs hizmetlerine buradan ulaşabilirsin.",
                  style: TextStyle(color: Colors.white, height: 1.4),
                ),
              ],
            ),
          ),
          if (logoGoster) ...[
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(Tema.kose)),
              child: Image.asset('assets/images/au_logo.png', height: 64),
            ),
          ],
        ],
      ),
    );
  }
}

class _ModulKartlari extends StatelessWidget {
  const _ModulKartlari({required this.genislik});

  final double genislik;

  @override
  Widget build(BuildContext context) {
    final sutun = genislik >= 1200 ? 3 : (genislik >= 600 ? 2 : 1);

    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: sutun,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 96,
      ),
      children: [for (final modul in Moduller.hepsi) _ModulKarti(modul: modul)],
    );
  }
}

class _ModulKarti extends StatelessWidget {
  const _ModulKarti({required this.modul});

  final Modul modul;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, modul.rota),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: Renkler.vurgu, borderRadius: BorderRadius.circular(Tema.kose)),
                child: Icon(modul.ikon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      modul.baslik,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600, color: Renkler.yazi),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      modul.aciklama,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, color: Renkler.yaziSoluk),
                    ),
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

class _DuyuruSatiri extends StatelessWidget {
  const _DuyuruSatiri({required this.duyuru});

  final Duyuru duyuru;

  @override
  Widget build(BuildContext context) {
    final tarih = duyuru.yayinTarihi;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 56,
            decoration: BoxDecoration(
              border: Border.all(color: Renkler.kenar),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${tarih.day}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Renkler.vurgu),
                ),
                Text(TurkceTarih.kisaAy(tarih), style: const TextStyle(fontSize: 12, color: Renkler.yaziSoluk)),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (duyuru.onemliMi) const Rozet.onemli(),
                    Text(
                      duyuru.baslik,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Renkler.yazi),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(duyuru.icerik, style: const TextStyle(color: Renkler.yazi, height: 1.4)),
                const SizedBox(height: 6),
                Text(
                  '${duyuru.yazarAdi} · ${TurkceTarih.saatli(tarih)}',
                  style: const TextStyle(fontSize: 12, color: Renkler.yaziSoluk),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
