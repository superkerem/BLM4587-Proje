import 'package:flutter/material.dart';

import '../../core/constants/api_constants.dart';
import '../../core/roller.dart';
import '../../core/tema.dart';
import '../../models/kullanici.dart';
import '../../services/api_istemcisi.dart';
import '../../services/oturum_servisi.dart';
import '../../widgets/panel_ogeleri.dart';
import '../erisim_engellendi_ekrani.dart';

class KullanicilarEkrani extends StatefulWidget {
  const KullanicilarEkrani({super.key});

  @override
  State<KullanicilarEkrani> createState() => _KullanicilarEkraniState();
}

class _KullanicilarEkraniState extends State<KullanicilarEkrani> {
  late Future<List<Kullanici>> _kullanicilar;

  @override
  void initState() {
    super.initState();
    _kullanicilar = _getir();
  }

  Future<List<Kullanici>> _getir() async {
    final liste = await OturumServisi.ornek.api.get(ApiSabitleri.yonetimKullanicilar) as List<dynamic>;
    return liste.map((e) => Kullanici.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> _yenile() async {
    final yeni = _getir();
    setState(() => _kullanicilar = yeni);
    await yeni.catchError((_) => <Kullanici>[]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Kullanici>>(
      future: _kullanicilar,
      builder: (context, durum) {
        final hata = durum.error;
        if (hata is ApiHatasi && hata.erisimEngellendi) {
          return const ErisimEngellendiEkrani();
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Yönetim Paneli')),
          body: RefreshIndicator(
            onRefresh: _yenile,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                const SayfaBasligi(baslik: 'Yönetim Paneli', aciklama: 'Kayıtlı kullanıcılar ve rolleri'),
                _icerik(durum),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _icerik(AsyncSnapshot<List<Kullanici>> durum) {
    if (durum.connectionState != ConnectionState.done) {
      return const PanelKart(child: Center(child: CircularProgressIndicator()));
    }

    if (durum.hasError) {
      return BosDurum(
        ikon: Icons.cloud_off,
        baslik: 'Kullanıcılar yüklenemedi',
        aciklama: durum.error.toString(),
        dugmeMetni: 'Tekrar Dene',
        dugmeyeBasilinca: _yenile,
      );
    }

    final kullanicilar = durum.data!;
    if (kullanicilar.isEmpty) {
      return const BosDurum(
        ikon: Icons.people_outline,
        baslik: 'Kayıtlı kullanıcı yok',
        aciklama: 'Kayıt olan kullanıcılar burada listelenecek.',
      );
    }

    return PanelKart(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < kullanicilar.length; i++) ...[
            if (i > 0) const Divider(),
            _KullaniciSatiri(kullanici: kullanicilar[i]),
          ],
        ],
      ),
    );
  }
}

class _KullaniciSatiri extends StatelessWidget {
  const _KullaniciSatiri({required this.kullanici});

  final Kullanici kullanici;

  @override
  Widget build(BuildContext context) {
    final k = kullanici;
    final t = k.kayitTarihi;
    final kayit = '${t.day.toString().padLeft(2, '0')}.${t.month.toString().padLeft(2, '0')}.${t.year}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: k.yoneticiMi ? Renkler.vurgu : Renkler.arka,
            child: Text(
              k.ad.isEmpty ? '?' : k.ad[0].toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: k.yoneticiMi ? Colors.white : Renkler.yaziSoluk,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(k.adSoyad, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  [k.email ?? '', if (k.ogrenciNo != null) 'No: ${k.ogrenciNo}', 'Kayıt: $kayit'].join(' · '),
                  style: const TextStyle(fontSize: 12, color: Renkler.yaziSoluk),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Wrap(
            spacing: 4,
            children: [
              for (final rol in k.roller)
                rol == Roller.yonetici ? Rozet.yonetici(metin: rol) : Rozet.kullanici(metin: rol),
            ],
          ),
        ],
      ),
    );
  }
}
