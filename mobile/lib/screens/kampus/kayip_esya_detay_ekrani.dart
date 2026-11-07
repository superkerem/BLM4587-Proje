import 'package:flutter/material.dart';

import '../../core/tema.dart';
import '../../models/kayip_esya.dart';
import '../../services/api_istemcisi.dart';
import '../../services/kayip_esya_servisi.dart';
import '../../services/oturum_servisi.dart';
import '../../widgets/panel_ogeleri.dart';

class KayipEsyaDetayEkrani extends StatefulWidget {
  const KayipEsyaDetayEkrani({super.key, required this.esya});

  final KayipEsya esya;

  @override
  State<KayipEsyaDetayEkrani> createState() => _KayipEsyaDetayEkraniState();
}

class _KayipEsyaDetayEkraniState extends State<KayipEsyaDetayEkrani> {
  late KayipEsya _esya = widget.esya;
  bool _degisti = false;
  bool _siliniyor = false;

  // API ile aynı kural: ilanı sadece ekleyen kişi ya da yönetici değiştirebilir.
  bool get _duzenleyebilir {
    final oturum = OturumServisi.ornek;
    return oturum.kullanici?.id == _esya.bildirenId || oturum.yoneticiMi;
  }

  Future<void> _duzenle() async {
    final guncel = await Navigator.pushNamed(context, '/kampus/kayip-esya/form', arguments: _esya);
    if (guncel is KayipEsya && mounted) {
      setState(() {
        _esya = guncel;
        _degisti = true;
      });
    }
  }

  Future<void> _sil() async {
    final onay = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('İlanı sil'),
        content: Text('"${_esya.baslik}" ilanı kalıcı olarak silinecek. Emin misiniz?'),
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

    final navigator = Navigator.of(context);
    final mesajci = ScaffoldMessenger.of(context);
    setState(() => _siliniyor = true);
    try {
      await KayipEsyaServisi.sil(_esya.id);
      mesajci.showSnackBar(const SnackBar(content: Text('İlan silindi.')));
      navigator.pop(true);
    } on ApiHatasi catch (hata) {
      mesajci.showSnackBar(SnackBar(content: Text(hata.mesaj)));
      if (mounted) setState(() => _siliniyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.pop(context, _degisti);
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('İlan Detayı')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            PanelKart(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _esya.baslik,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Renkler.yazi),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _esya.teslimEdildiMi
                          ? const Rozet(metin: 'Teslim edildi', arkaPlan: Renkler.vurguAcik, yaziRengi: Renkler.vurgu)
                          : const Rozet(metin: 'Bekliyor', arkaPlan: Renkler.arka, yaziRengi: Renkler.yaziSoluk),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(_esya.aciklama, style: const TextStyle(color: Renkler.yazi, height: 1.4)),
                  const Divider(height: 32),
                  _Bilgi(ikon: Icons.place_outlined, etiket: 'Bulunduğu Yer', deger: _esya.bulunanYer),
                  _Bilgi(ikon: Icons.event_outlined, etiket: 'Bulunma Tarihi', deger: _esya.tarihMetni),
                  _Bilgi(ikon: Icons.person_outline, etiket: 'Bildiren', deger: _esya.bildirenAdi),
                ],
              ),
            ),
            if (_duzenleyebilir) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _siliniyor ? null : _duzenle,
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Düzenle'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _siliniyor ? null : _sil,
                      style: OutlinedButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
                      icon: _siliniyor
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.delete_outline),
                      label: const Text('Sil'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Bilgi extends StatelessWidget {
  const _Bilgi({required this.ikon, required this.etiket, required this.deger});

  final IconData ikon;
  final String etiket;
  final String deger;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(ikon, size: 20, color: Renkler.vurgu),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(etiket, style: const TextStyle(fontSize: 12, color: Renkler.yaziSoluk)),
                const SizedBox(height: 2),
                Text(deger, style: const TextStyle(color: Renkler.yazi)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
