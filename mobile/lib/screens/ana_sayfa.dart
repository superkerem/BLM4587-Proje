import 'package:flutter/material.dart';

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
      body: ListView(
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
        ],
      ),
    );
  }
}
