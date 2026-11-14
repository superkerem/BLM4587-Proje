import 'package:flutter/material.dart';

import '../../core/tema.dart';
import '../../models/duyuru.dart';
import '../../services/api_istemcisi.dart';
import '../../services/duyuru_servisi.dart';
import '../../widgets/panel_ogeleri.dart';

class DuyurularEkrani extends StatefulWidget {
  const DuyurularEkrani({super.key});

  @override
  State<DuyurularEkrani> createState() => _DuyurularEkraniState();
}

class _DuyurularEkraniState extends State<DuyurularEkrani> {
  late Future<List<Duyuru>> _duyurular = DuyuruServisi.listele(adet: 100);
  final Set<int> _silinenler = {};

  Future<void> _yenile() async {
    final yeni = DuyuruServisi.listele(adet: 100);
    setState(() {
      _duyurular = yeni;
    });
    try {
      await yeni;
    } catch (_) {
      // Hata FutureBuilder içinde gösterilir.
    }
  }

  Future<void> _formuAc([Duyuru? duyuru]) async {
    final kaydedildi = await Navigator.pushNamed(context, '/yonetim/duyuru-form', arguments: duyuru);
    if (kaydedildi == true) _yenile();
  }

  Future<void> _sil(Duyuru duyuru) async {
    final onay = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Duyuruyu sil'),
        content: Text('"${duyuru.baslik}" duyurusu kalıcı olarak silinecek. Emin misiniz?'),
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
      _silinenler.add(duyuru.id);
    });
    try {
      await DuyuruServisi.sil(duyuru.id);
      mesajci.showSnackBar(const SnackBar(content: Text('Duyuru silindi.')));
      await _yenile();
    } on ApiHatasi catch (hata) {
      mesajci.showSnackBar(SnackBar(content: Text(hata.mesaj)));
    } finally {
      if (mounted) {
        setState(() {
          _silinenler.remove(duyuru.id);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Duyuru Yönetimi')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _formuAc(),
        icon: const Icon(Icons.add),
        label: const Text('Duyuru Ekle'),
      ),
      body: RefreshIndicator(
        onRefresh: _yenile,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
          children: [
            const SayfaBasligi(
              baslik: 'Duyuru Yönetimi',
              aciklama: 'Ana sayfada görünen duyuruları ekleyin, düzenleyin veya silin.',
            ),
            _duyuruListesi(),
          ],
        ),
      ),
    );
  }

  Widget _duyuruListesi() {
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
            aciklama: 'İlk duyuruyu "Duyuru Ekle" düğmesiyle paylaşabilirsiniz.',
          );
        }

        return Column(
          children: [
            for (final duyuru in duyurular)
              _DuyuruKarti(
                duyuru: duyuru,
                siliniyor: _silinenler.contains(duyuru.id),
                onTap: () => _formuAc(duyuru),
                onSil: () => _sil(duyuru),
              ),
          ],
        );
      },
    );
  }
}

class _DuyuruKarti extends StatelessWidget {
  const _DuyuruKarti({
    required this.duyuru,
    required this.siliniyor,
    required this.onTap,
    required this.onSil,
  });

  final Duyuru duyuru;
  final bool siliniyor;
  final VoidCallback onTap;
  final VoidCallback onSil;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Tema.kose),
        child: PanelKart(
          padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
          child: Row(
            children: [
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
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Renkler.yazi),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      duyuru.icerik,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Renkler.yazi, height: 1.4),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${duyuru.yazarAdi} · ${TurkceTarih.saatli(duyuru.yayinTarihi)}',
                      style: const TextStyle(fontSize: 12, color: Renkler.yaziSoluk),
                    ),
                  ],
                ),
              ),
              siliniyor
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : IconButton(
                      onPressed: onSil,
                      tooltip: 'Sil',
                      icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
