import 'package:flutter/material.dart';

import '../../core/tema.dart';
import '../../models/sinav.dart';
import '../../services/api_istemcisi.dart';
import '../../services/sinav_servisi.dart';
import '../../widgets/panel_ogeleri.dart';
import '../../widgets/sinav_satiri.dart';

class SinavlarEkrani extends StatefulWidget {
  const SinavlarEkrani({super.key});

  @override
  State<SinavlarEkrani> createState() => _SinavlarEkraniState();
}

class _SinavlarEkraniState extends State<SinavlarEkrani> {
  late Future<YonetimSinavlari> _sinavlar = SinavServisi.yonetimListele();
  final Set<int> _silinenler = {};

  Future<void> _yenile() async {
    final yeni = SinavServisi.yonetimListele();
    setState(() {
      _sinavlar = yeni;
    });
    try {
      await yeni;
    } on Exception catch (_) {
      return;
    }
  }

  Future<void> _formuAc([Sinav? sinav]) async {
    final kaydedildi = await Navigator.pushNamed(context, '/yonetim/sinav-form', arguments: sinav?.id);
    if (kaydedildi == true) _yenile();
  }

  Future<void> _sil(Sinav sinav) async {
    final tarih = '${sinav.tarih.day} ${TurkceTarih.aylar[sinav.tarih.month - 1]}';
    final onay = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sınavı sil'),
        content: Text('${sinav.dersKodu} ${sinav.tur.etiket} ($tarih) sınavı ve tüm derslik kayıtları silinecek.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Vazgeç')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    if (onay != true || !mounted) return;

    final mesajci = ScaffoldMessenger.of(context);
    setState(() {
      _silinenler.add(sinav.id);
    });
    try {
      await SinavServisi.sil(sinav.id);
      mesajci.showSnackBar(const SnackBar(content: Text('Sınav silindi.')));
      await _yenile();
    } on ApiHatasi catch (hata) {
      mesajci.showSnackBar(SnackBar(content: Text(hata.mesaj)));
    } finally {
      if (mounted) {
        setState(() {
          _silinenler.remove(sinav.id);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sınav Takvimi')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _formuAc(),
        icon: const Icon(Icons.add),
        label: const Text('Sınav Ekle'),
      ),
      body: RefreshIndicator(
        onRefresh: _yenile,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
          children: [
            const SayfaBasligi(
              baslik: 'Sınav Takvimi',
              aciklama: 'Sınavların tarihini, saatini ve dersliklerini girin.',
            ),
            _icerik(),
          ],
        ),
      ),
    );
  }

  Widget _icerik() {
    return FutureBuilder<YonetimSinavlari>(
      future: _sinavlar,
      builder: (context, durum) {
        if (durum.connectionState != ConnectionState.done) {
          return const PanelKart(child: Center(child: CircularProgressIndicator()));
        }

        if (durum.hasError) {
          return BosDurum(
            ikon: Icons.cloud_off,
            baslik: 'Sınavlar yüklenemedi',
            aciklama: durum.error.toString(),
            dugmeMetni: 'Tekrar Dene',
            dugmeyeBasilinca: _yenile,
          );
        }

        final sinavlar = durum.data!;
        if (sinavlar.bosMu) {
          return const BosDurum(
            ikon: Icons.event_note_outlined,
            baslik: 'Henüz sınav yok',
            aciklama: 'Sınav tarihleri açıklandığında burada listelenecek.',
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const BolumBasligi('Yaklaşan Sınavlar'),
            _liste(sinavlar.yaklasanlar, 'Yaklaşan sınav yok.'),
            const SizedBox(height: 24),
            const BolumBasligi('Geçmiş Sınavlar'),
            _liste(sinavlar.gecmisler, 'Geçmiş sınav yok.'),
          ],
        );
      },
    );
  }

  Widget _liste(List<Sinav> sinavlar, String bosMetin) {
    if (sinavlar.isEmpty) {
      return PanelKart(
        child: Text(bosMetin, style: const TextStyle(color: Renkler.yaziSoluk)),
      );
    }

    return PanelKart(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < sinavlar.length; i++) ...[
            if (i > 0) const Divider(),
            SinavSatiri(
              sinav: sinavlar[i],
              haritaGosterilsin: false,
              onTap: () => _formuAc(sinavlar[i]),
              sonEk: _silinenler.contains(sinavlar[i].id)
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : IconButton(
                      onPressed: () => _sil(sinavlar[i]),
                      tooltip: 'Sil',
                      icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                    ),
            ),
          ],
        ],
      ),
    );
  }
}
