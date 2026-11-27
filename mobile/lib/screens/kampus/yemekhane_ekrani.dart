import 'package:flutter/material.dart';

import '../../core/moduller.dart';
import '../../core/tema.dart';
import '../../core/turkiye_saati.dart';
import '../../models/yemekhane.dart';
import '../../services/yemekhane_servisi.dart';
import '../../widgets/panel_ogeleri.dart';

const _aylar = [
  'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
  'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
];

const _gunAdlari = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];

DateTime _gunBasi(DateTime t) => DateTime(t.year, t.month, t.day);

bool _ayniGun(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

class YemekhaneEkrani extends StatelessWidget {
  const YemekhaneEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    final modul = Moduller.yemekhane;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(modul.baslik),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.restaurant_menu), text: 'Yemek Menüsü'),
              Tab(icon: Icon(Icons.storefront), text: 'Kantinler'),
            ],
          ),
        ),
        body: const TabBarView(children: [_MenuSekmesi(), _KantinSekmesi()]),
      ),
    );
  }
}

class _MenuSekmesi extends StatefulWidget {
  const _MenuSekmesi();

  @override
  State<_MenuSekmesi> createState() => _MenuSekmesiState();
}

class _MenuSekmesiState extends State<_MenuSekmesi> {
  final DateTime _bugun = _gunBasi(TurkiyeSaati.simdi());
  late DateTime _seciliGun = _bugun;
  late Future<List<YemekMenusu>> _menuler;
  final Future<List<YemekhaneBinasi>> _binalar = YemekhaneServisi.binalar();

  DateTime get _haftaBasi => _seciliGun.subtract(Duration(days: _seciliGun.weekday - 1));

  @override
  void initState() {
    super.initState();
    _menuler = YemekhaneServisi.haftalik(_seciliGun);
  }

  Future<void> _yenile() async {
    final yeni = YemekhaneServisi.haftalik(_seciliGun);
    setState(() => _menuler = yeni);
    await yeni.catchError((_) => <YemekMenusu>[]);
  }

  void _haftaDegistir(int hafta) {
    setState(() {
      _seciliGun = _haftaBasi.add(Duration(days: 7 * hafta));
      _menuler = YemekhaneServisi.haftalik(_seciliGun);
    });
  }

  void _gunSec(DateTime gun) => setState(() => _seciliGun = gun);

  void _bugune() {
    setState(() {
      _seciliGun = _bugun;
      _menuler = YemekhaneServisi.haftalik(_seciliGun);
    });
  }

  String _gunEtiketi(DateTime gun) {
    final ad = '${gun.day} ${_aylar[gun.month - 1]} ${_gunAdlari[gun.weekday - 1]}';
    if (_ayniGun(gun, _bugun)) return 'Bugün · $ad';
    if (_ayniGun(gun, _bugun.add(const Duration(days: 1)))) return 'Yarın · $ad';
    return ad;
  }

  @override
  Widget build(BuildContext context) {
    final haftaBasi = _haftaBasi;
    final haftaSonu = haftaBasi.add(const Duration(days: 4));
    final haftaGunleri = [for (var i = 0; i < 5; i++) haftaBasi.add(Duration(days: i))];

    return RefreshIndicator(
      onRefresh: _yenile,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Önceki hafta',
                onPressed: () => _haftaDegistir(-1),
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Text(
                  '${haftaBasi.day} ${_aylar[haftaBasi.month - 1]} - ${haftaSonu.day} ${_aylar[haftaSonu.month - 1]}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w600, color: Renkler.yazi),
                ),
              ),
              IconButton(
                tooltip: 'Sonraki hafta',
                onPressed: () => _haftaDegistir(1),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              for (final gun in haftaGunleri)
                ChoiceChip(
                  label: Text('${TurkiyeSaati.kisaGunler[gun.weekday - 1]} ${gun.day}'),
                  selected: _ayniGun(gun, _seciliGun),
                  onSelected: (_) => _gunSec(gun),
                ),
            ],
          ),
          if (!_ayniGun(_seciliGun, _bugun))
            Center(child: TextButton(onPressed: _bugune, child: const Text('Bugüne dön'))),
          const SizedBox(height: 16),
          BolumBasligi(_gunEtiketi(_seciliGun)),
          FutureBuilder<List<YemekMenusu>>(
            future: _menuler,
            builder: (context, durum) {
              if (durum.connectionState != ConnectionState.done) {
                return const PanelKart(child: Center(child: CircularProgressIndicator()));
              }
              if (durum.hasError) {
                return BosDurum(
                  ikon: Icons.cloud_off,
                  baslik: 'Menü yüklenemedi',
                  aciklama: durum.error.toString(),
                  dugmeMetni: 'Tekrar Dene',
                  dugmeyeBasilinca: _yenile,
                );
              }

              final menu = durum.data!.where((m) => _ayniGun(m.tarih, _seciliGun)).firstOrNull;
              if (menu == null) {
                final haftaSonuMu = _seciliGun.weekday >= DateTime.saturday;
                return BosDurum(
                  ikon: Icons.event_busy,
                  baslik: 'Bu gün için menü yok',
                  aciklama: haftaSonuMu
                      ? 'Hafta sonları yemekhane menüsü yayımlanmıyor.'
                      : 'Bu günün menüsü henüz girilmedi.',
                );
              }
              return _MenuKarti(menu: menu);
            },
          ),
          const SizedBox(height: 12),
          FutureBuilder<List<YemekhaneBinasi>>(
            future: _binalar,
            builder: (context, durum) {
              final binalar = durum.data ?? const <YemekhaneBinasi>[];
              return Column(
                children: [for (final bina in binalar) _YemekhaneBinasiSatiri(bina: bina)],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _YemekhaneBinasiSatiri extends StatelessWidget {
  const _YemekhaneBinasiSatiri({required this.bina});

  final YemekhaneBinasi bina;

  @override
  Widget build(BuildContext context) {
    return PanelKart(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.restaurant, color: Renkler.vurgu),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Yemekhane', style: TextStyle(fontSize: 12, color: Renkler.yaziSoluk)),
                Text(bina.ad, style: const TextStyle(fontWeight: FontWeight.w600, color: Renkler.yazi)),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/kampus/harita', arguments: bina.id),
            icon: const Icon(Icons.place_outlined, size: 18),
            label: const Text('Haritada göster'),
          ),
        ],
      ),
    );
  }
}

class _MenuKarti extends StatelessWidget {
  const _MenuKarti({required this.menu});

  final YemekMenusu menu;

  @override
  Widget build(BuildContext context) {
    return PanelKart(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MenuSatiri(etiket: 'Çorba', yemek: menu.corba),
          _MenuSatiri(etiket: 'Ana Yemek', yemek: menu.anaYemek),
          if (menu.yanYemek?.isNotEmpty ?? false) _MenuSatiri(etiket: 'Yan Yemek', yemek: menu.yanYemek!),
          if (menu.tatli?.isNotEmpty ?? false) _MenuSatiri(etiket: 'Tatlı / Meyve', yemek: menu.tatli!),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (menu.vejetaryenSecenek?.isNotEmpty ?? false)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.eco_outlined, size: 18, color: Color(0xFF1A7F37)),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Vejetaryen: ${menu.vejetaryenSecenek}',
                        style: const TextStyle(color: Color(0xFF1A7F37)),
                      ),
                    ),
                  ],
                ),
              if (menu.kalori != null) Rozet.kullanici(metin: '${menu.kalori} kcal'),
            ],
          ),
        ],
      ),
    );
  }
}

class _MenuSatiri extends StatelessWidget {
  const _MenuSatiri({required this.etiket, required this.yemek});

  final String etiket;
  final String yemek;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              etiket,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Renkler.yaziSoluk),
            ),
          ),
          Expanded(
            child: Text(yemek, style: const TextStyle(fontWeight: FontWeight.w500, color: Renkler.yazi)),
          ),
        ],
      ),
    );
  }
}

class _KantinSekmesi extends StatefulWidget {
  const _KantinSekmesi();

  @override
  State<_KantinSekmesi> createState() => _KantinSekmesiState();
}

class _KantinSekmesiState extends State<_KantinSekmesi> {
  late Future<List<Kantin>> _kantinler = YemekhaneServisi.kantinler();

  Future<void> _yenile() async {
    final yeni = YemekhaneServisi.kantinler();
    setState(() => _kantinler = yeni);
    await yeni.catchError((_) => <Kantin>[]);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _yenile,
      child: FutureBuilder<List<Kantin>>(
        future: _kantinler,
        builder: (context, durum) {
          final Widget icerik;
          if (durum.connectionState != ConnectionState.done) {
            icerik = const PanelKart(child: Center(child: CircularProgressIndicator()));
          } else if (durum.hasError) {
            icerik = BosDurum(
              ikon: Icons.cloud_off,
              baslik: 'Kantinler yüklenemedi',
              aciklama: durum.error.toString(),
              dugmeMetni: 'Tekrar Dene',
              dugmeyeBasilinca: _yenile,
            );
          } else if (durum.data!.isEmpty) {
            icerik = const BosDurum(
              ikon: Icons.storefront,
              baslik: 'Kayıtlı kantin yok',
              aciklama: 'Kampüs kantinleri eklendiğinde burada listelenecek.',
            );
          } else {
            icerik = Column(children: [for (final kantin in durum.data!) _KantinKarti(kantin: kantin)]);
          }

          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [icerik],
          );
        },
      ),
    );
  }
}

class _KantinKarti extends StatelessWidget {
  const _KantinKarti({required this.kantin});

  final Kantin kantin;

  @override
  Widget build(BuildContext context) {
    final kategoriler = kantin.kategoriler;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: PanelKart(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.storefront, color: Renkler.vurgu),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    kantin.ad,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Renkler.yazi),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/kampus/harita', arguments: kantin.id),
                  icon: const Icon(Icons.place_outlined, size: 18),
                  label: const Text('Haritada göster'),
                ),
              ],
            ),
            if (kategoriler.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('Bu kantin için ürün bilgisi henüz girilmedi.', style: TextStyle(color: Renkler.yaziSoluk)),
              ),
            for (final kategori in kategoriler.entries) ...[
              const SizedBox(height: 12),
              Text(
                KantinUrunu.kategoriAdi(kategori.key),
                style: const TextStyle(fontWeight: FontWeight.w600, color: Renkler.vurgu),
              ),
              for (final urun in kategori.value) _UrunSatiri(urun: urun),
            ],
          ],
        ),
      ),
    );
  }
}

class _UrunSatiri extends StatelessWidget {
  const _UrunSatiri({required this.urun});

  final KantinUrunu urun;

  @override
  Widget build(BuildContext context) {
    final renk = urun.mevcutMu ? Renkler.yazi : Renkler.yaziSoluk;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Renkler.kenar))),
      child: Row(
        children: [
          Expanded(child: Text(urun.ad, style: TextStyle(color: renk))),
          if (!urun.mevcutMu) ...[
            const Rozet.kullanici(metin: 'Tükendi'),
            const SizedBox(width: 8),
          ],
          Text(urun.fiyatMetni, style: TextStyle(fontWeight: FontWeight.w600, color: renk)),
        ],
      ),
    );
  }
}
