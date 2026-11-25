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
                const SayfaBasligi(
                  baslik: 'Yönetim Paneli',
                  aciklama: 'Portal içeriği, kayıtlı kullanıcılar ve rolleri',
                ),
                const _YonetimModulleri(),
                const SizedBox(height: 24),
                const BolumBasligi('Kullanıcılar'),
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

class _YonetimModulleri extends StatelessWidget {
  const _YonetimModulleri();

  @override
  Widget build(BuildContext context) {
    const kartlar = [
      _ModulKarti(
        ikon: Icons.campaign_outlined,
        baslik: 'Duyuru Yönetimi',
        aciklama: 'Ana sayfadaki duyuruları ekleyin, düzenleyin veya silin.',
        rota: '/yonetim/duyurular',
      ),
      _ModulKarti(
        ikon: Icons.event_note_outlined,
        baslik: 'Sınav Takvimi',
        aciklama: 'Sınavların tarihini, saatini ve dersliklerini girin.',
        rota: '/yonetim/sinavlar',
      ),
    ];

    return LayoutBuilder(
      builder: (context, kisitlar) {
        if (kisitlar.maxWidth < 520) {
          return Column(
            children: [
              for (var i = 0; i < kartlar.length; i++) ...[
                if (i > 0) const SizedBox(height: 12),
                kartlar[i],
              ],
            ],
          );
        }

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < kartlar.length; i++) ...[
                if (i > 0) const SizedBox(width: 12),
                Expanded(child: kartlar[i]),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ModulKarti extends StatelessWidget {
  const _ModulKarti({required this.ikon, required this.baslik, required this.aciklama, required this.rota});

  final IconData ikon;
  final String baslik;
  final String aciklama;
  final String rota;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, rota),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Renkler.vurguAcik,
                  borderRadius: BorderRadius.circular(Tema.kose),
                ),
                child: Icon(ikon, color: Renkler.vurgu),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(baslik, style: const TextStyle(fontWeight: FontWeight.w600, color: Renkler.yazi)),
                    const SizedBox(height: 2),
                    Text(aciklama, style: const TextStyle(fontSize: 13, color: Renkler.yaziSoluk)),
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
