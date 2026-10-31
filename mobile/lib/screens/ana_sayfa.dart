import 'package:flutter/material.dart';

import '../core/moduller.dart';
import '../services/oturum_servisi.dart';

class AnaSayfa extends StatelessWidget {
  const AnaSayfa({super.key});

  Future<void> _cikisYap(BuildContext context) async {
    final mesajci = ScaffoldMessenger.of(context);
    await OturumServisi.ornek.cikisYap();
    mesajci.showSnackBar(const SnackBar(content: Text('Başarıyla çıkış yaptınız.')));
  }

  @override
  Widget build(BuildContext context) {
    final oturum = OturumServisi.ornek;
    return ListenableBuilder(
      listenable: oturum,
      builder: (context, _) => _sayfa(context, oturum),
    );
  }

  Widget _sayfa(BuildContext context, OturumServisi oturum) {
    final kullanici = oturum.kullanici;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AÜ Hub'),
        actions: [
          IconButton(
            tooltip: 'Çıkış Yap',
            icon: const Icon(Icons.logout),
            onPressed: () => _cikisYap(context),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Colors.blue.shade700),
              accountName: Text(kullanici?.adSoyad ?? ''),
              accountEmail: Text(kullanici?.email ?? ''),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  (kullanici?.ad.isNotEmpty ?? false) ? kullanici!.ad[0] : '?',
                  style: TextStyle(fontSize: 24, color: Colors.blue.shade700),
                ),
              ),
            ),
            const ListTile(leading: Icon(Icons.home), title: Text('Ana Sayfa')),
            // Web'deki _GirisPartial gibi: yönetim bağlantısı yalnızca Yönetici rolüne görünür.
            if (oturum.yoneticiMi)
              ListTile(
                leading: const Icon(Icons.admin_panel_settings),
                title: const Text('Yönetim Paneli'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/yonetim/kullanicilar');
                },
              ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Çıkış Yap'),
              onTap: () {
                Navigator.pop(context);
                _cikisYap(context);
              },
            ),
          ],
        ),
      ),
      // Web'deki Bootstrap sütunlarının (col-12 col-md-6 col-lg-4) karşılığı:
      // ekran genişliğine göre telefonda 2, tablette (600 px üstü) 3 sütun.
      body: LayoutBuilder(
        builder: (context, kisitlar) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Hoş geldin, ${kullanici?.ad ?? ''}!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              oturum.yoneticiMi ? 'Rol: Yönetici' : 'Rol: Kullanıcı',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            _modulKartlari(kisitlar.maxWidth > 600 ? 3 : 2),
          ],
        ),
      ),
    );
  }

  Widget _modulKartlari(int sutunSayisi) {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: sutunSayisi,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 140,
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
    final renkler = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, modul.rota),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(modul.ikon, size: 40, color: renkler.primary),
              const SizedBox(height: 12),
              Flexible(
                child: Text(
                  modul.baslik,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
