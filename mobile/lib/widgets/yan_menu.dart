import 'package:flutter/material.dart';

import '../core/moduller.dart';
import '../core/tema.dart';
import '../services/oturum_servisi.dart';

class YanMenu extends StatelessWidget {
  const YanMenu({super.key, this.aktifRota = '/'});

  final String aktifRota;

  void _git(BuildContext context, String rota) {
    Navigator.pop(context);
    if (rota != aktifRota) Navigator.pushNamed(context, rota);
  }

  Future<void> _cikisYap(BuildContext context) async {
    final mesajci = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    await OturumServisi.ornek.cikisYap();
    mesajci.showSnackBar(const SnackBar(content: Text('Başarıyla çıkış yaptınız.')));
  }

  @override
  Widget build(BuildContext context) {
    final oturum = OturumServisi.ornek;
    final kullanici = oturum.kullanici;
    final adSoyad = kullanici?.adSoyad ?? '';

    return Drawer(
      width: 280,
      backgroundColor: Renkler.yuzey,
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  Image.asset('assets/images/au_logo.png', height: 36),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('AÜ Hub', style: TextStyle(fontWeight: FontWeight.w700, color: Renkler.vurgu)),
                      Text('Kampüs Portalı', style: TextStyle(fontSize: 12, color: Renkler.yaziSoluk)),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(8),
                children: [
                  _MenuBaglantisi(
                    ikon: Icons.dashboard_outlined,
                    baslik: 'Ana Sayfa',
                    aktif: aktifRota == '/',
                    onTap: () => _git(context, '/'),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(12, 16, 12, 6),
                    child: Text(
                      'MODÜLLER',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.6,
                        color: Renkler.yaziSoluk,
                      ),
                    ),
                  ),
                  for (final modul in Moduller.hepsi)
                    _MenuBaglantisi(
                      ikon: modul.ikon,
                      baslik: modul.baslik,
                      aktif: aktifRota == modul.rota,
                      onTap: () => _git(context, modul.rota),
                    ),
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  if (oturum.yoneticiMi)
                    _MenuBaglantisi(
                      ikon: Icons.admin_panel_settings_outlined,
                      baslik: 'Yönetim Paneli',
                      aktif: aktifRota == '/yonetim/kullanicilar',
                      onTap: () => _git(context, '/yonetim/kullanicilar'),
                    ),
                  if (oturum.yoneticiMi)
                    _MenuBaglantisi(
                      ikon: Icons.campaign_outlined,
                      baslik: 'Duyuru Yönetimi',
                      aktif: aktifRota.startsWith('/yonetim/duyuru'),
                      onTap: () => _git(context, '/yonetim/duyurular'),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 0, 4),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Renkler.vurgu,
                          child: Text(
                            adSoyad.isEmpty ? '?' : adSoyad[0].toUpperCase(),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                adSoyad,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                              ),
                              Text(
                                kullanici?.email ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12, color: Renkler.yaziSoluk),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Çıkış Yap',
                          icon: const Icon(Icons.logout, size: 20),
                          color: Renkler.yaziSoluk,
                          onPressed: () => _cikisYap(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuBaglantisi extends StatelessWidget {
  const _MenuBaglantisi({required this.ikon, required this.baslik, required this.aktif, required this.onTap});

  final IconData ikon;
  final String baslik;
  final bool aktif;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      leading: Icon(ikon, size: 20, color: aktif ? Renkler.vurgu : Renkler.yaziSoluk),
      title: Text(
        baslik,
        style: TextStyle(
          fontSize: 14,
          fontWeight: aktif ? FontWeight.w600 : FontWeight.w400,
          color: aktif ? Renkler.vurgu : Renkler.yazi,
        ),
      ),
      selected: aktif,
      selectedTileColor: Renkler.vurguAcik,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      onTap: onTap,
    );
  }
}
