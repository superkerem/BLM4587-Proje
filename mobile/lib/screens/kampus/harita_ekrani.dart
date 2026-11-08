import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../core/moduller.dart';
import '../../core/tema.dart';
import '../../models/mekan.dart';
import '../../services/kampus_servisi.dart';
import '../../widgets/panel_ogeleri.dart';

class HaritaEkrani extends StatefulWidget {
  const HaritaEkrani({super.key, this.seciliMekanId});

  final int? seciliMekanId;

  @override
  State<HaritaEkrani> createState() => _HaritaEkraniState();
}

class _BinaRenkleri {
  const _BinaRenkleri(this.cati, this.onDuvar, this.yanDuvar, this.kenar);

  final Color cati;
  final Color onDuvar;
  final Color yanDuvar;
  final Color kenar;
}

class _HaritaEkraniState extends State<HaritaEkrani> {
  static const _kampusMerkezi = LatLng(39.7802, 32.8205);
  static final _kampusSiniri = LatLngBounds(const LatLng(39.7735, 32.8075), const LatLng(39.7875, 32.8335));
  static const _ilkYakinlik = 16.4;
  static const _secimYakinligi = 18.0;
  static const _etiketYakinligi = 17.3;

  static const _akademikRenkleri = _BinaRenkleri(
    Color(0xFF0E4A87),
    Color(0xFF0A3866),
    Color(0xFF072B4F),
    Color(0xFF072B4F),
  );
  static const _hizmetRenkleri = _BinaRenkleri(
    Color(0xFF3F72A6),
    Color(0xFF2D5A88),
    Color(0xFF22476D),
    Color(0xFF22476D),
  );
  static const _yurtRenkleri = _BinaRenkleri(
    Color(0xFF8EAACB),
    Color(0xFF7290B3),
    Color(0xFF5E7A9B),
    Color(0xFF5E7A9B),
  );
  static const _digerRenkleri = _BinaRenkleri(
    Color(0xFFB4C3D4),
    Color(0xFF97A8BB),
    Color(0xFF8395AA),
    Color(0xFF8395AA),
  );
  static const _adsizRenkleri = _BinaRenkleri(
    Color(0xFFD3D6DA),
    Color(0xFFB8BCC1),
    Color(0xFFA5AAB0),
    Color(0xFFA5AAB0),
  );
  static const _seciliRenkleri = _BinaRenkleri(
    Color(0xFFF2C94C),
    Color(0xFFC9A537),
    Color(0xFFA9892A),
    Color(0xFF8A6F1E),
  );

  final _haritaKontrolcusu = MapController();
  final _etiketlerGorunur = ValueNotifier<bool>(false);

  List<Mekan> _mekanlar = [];
  bool _yukleniyor = true;
  String? _hata;
  MekanTuru? _filtre;
  Mekan? _secili;

  List<Polygon> _cokgenler = [];
  String? _cokgenAnahtari;

  @override
  void initState() {
    super.initState();
    _yukle();
  }

  @override
  void dispose() {
    _etiketlerGorunur.dispose();
    super.dispose();
  }

  Future<void> _yukle() async {
    setState(() {
      _yukleniyor = true;
      _hata = null;
    });
    try {
      final mekanlar = await KampusServisi.mekanlar();
      if (!mounted) return;
      setState(() {
        _mekanlar = mekanlar;
        _secili = _mekanBul(widget.seciliMekanId);
        _etiketlerGorunur.value = (_secili != null ? _secimYakinligi : _ilkYakinlik) >= _etiketYakinligi;
        _yukleniyor = false;
      });
    } catch (hata) {
      if (!mounted) return;
      setState(() {
        _hata = hata.toString();
        _yukleniyor = false;
      });
    }
  }

  Mekan? _mekanBul(int? id) {
    if (id == null) return null;
    for (final mekan in _mekanlar) {
      if (mekan.id == id && !mekan.adsizMi) return mekan;
    }
    return null;
  }

  List<Mekan> get _adliMekanlar => _mekanlar.where((m) => !m.adsizMi).toList();

  List<MekanTuru> get _filtreTurleri {
    final mevcut = _adliMekanlar.map((m) => m.tur).toSet();
    return MekanTuru.values.where(mevcut.contains).toList();
  }

  bool _filtredeMi(Mekan mekan) => _filtre == null || mekan.tur == _filtre;

  List<Mekan> get _listedekiMekanlar =>
      _adliMekanlar.where(_filtredeMi).toList()..sort((a, b) => a.ad!.compareTo(b.ad!));

  double _yukseklik(Mekan mekan) {
    if (mekan.adsizMi) return 0.00004;
    return switch (mekan.tur) {
      MekanTuru.fakulte => 0.00007,
      MekanTuru.yurt => 0.00009,
      MekanTuru.diger => 0.00005,
      _ => 0.00004,
    };
  }

  _BinaRenkleri _renkler(Mekan mekan) {
    if (mekan.id == _secili?.id) return _seciliRenkleri;
    if (mekan.adsizMi || !_filtredeMi(mekan)) return _adsizRenkleri;
    return switch (mekan.tur) {
      MekanTuru.fakulte => _akademikRenkleri,
      MekanTuru.kutuphane || MekanTuru.yemekhane || MekanTuru.kantin || MekanTuru.ringDuragi => _hizmetRenkleri,
      MekanTuru.yurt => _yurtRenkleri,
      MekanTuru.diger => _digerRenkleri,
    };
  }

  LatLng _yukselt(LatLng nokta, double yukseklik) => LatLng(nokta.latitude + yukseklik, nokta.longitude);

  List<LatLng> _halkayiYukselt(List<LatLng> halka, double yukseklik) =>
      [for (final nokta in halka) _yukselt(nokta, yukseklik)];

  LatLng _catiMerkezi(Mekan mekan) => _yukselt(mekan.konum, _yukseklik(mekan));

  List<Polygon> _cokgenleriGetir() {
    final anahtar = '${_filtre?.name}-${_secili?.id}-${_mekanlar.length}';
    if (anahtar == _cokgenAnahtari) return _cokgenler;

    final sirali = [..._mekanlar]..sort((a, b) => b.konum.latitude.compareTo(a.konum.latitude));
    final liste = <Polygon>[];

    for (final mekan in sirali) {
      final renk = _renkler(mekan);
      final yukseklik = _yukseklik(mekan);

      for (final parca in mekan.parcalar) {
        if (parca.dis.length < 3) continue;

        liste.add(Polygon(
          points: [
            for (final nokta in parca.dis) LatLng(nokta.latitude - yukseklik * 0.2, nokta.longitude + yukseklik * 0.9),
          ],
          color: const Color(0x26000000),
          borderStrokeWidth: 0,
        ));

        final merkezEnlem = parca.dis.map((n) => n.latitude).reduce((a, b) => a + b) / parca.dis.length;
        for (var i = 0; i < parca.dis.length - 1; i++) {
          final a = parca.dis[i];
          final b = parca.dis[i + 1];
          final onYuzMu = (a.latitude + b.latitude) / 2 <= merkezEnlem;
          liste.add(Polygon(
            points: [a, b, _yukselt(b, yukseklik), _yukselt(a, yukseklik)],
            color: onYuzMu ? renk.onDuvar : renk.yanDuvar,
            borderColor: renk.kenar,
            borderStrokeWidth: 0.4,
          ));
        }

        liste.add(Polygon(
          points: _halkayiYukselt(parca.dis, yukseklik),
          holePointsList: [for (final delik in parca.delikler) _halkayiYukselt(delik, yukseklik)],
          color: renk.cati,
          borderColor: renk.kenar,
          borderStrokeWidth: 1,
        ));
      }
    }

    _cokgenAnahtari = anahtar;
    _cokgenler = liste;
    return liste;
  }

  bool _icindeMi(LatLng nokta, List<LatLng> halka) {
    var icinde = false;
    for (var i = 0, j = halka.length - 1; i < halka.length; j = i++) {
      final a = halka[i];
      final b = halka[j];
      final kesisir = (a.latitude > nokta.latitude) != (b.latitude > nokta.latitude) &&
          nokta.longitude <
              (b.longitude - a.longitude) * (nokta.latitude - a.latitude) / (b.latitude - a.latitude) + a.longitude;
      if (kesisir) icinde = !icinde;
    }
    return icinde;
  }

  Mekan? _dokunulanMekan(LatLng nokta) {
    final sirali = _adliMekanlar..sort((a, b) => a.konum.latitude.compareTo(b.konum.latitude));
    for (final mekan in sirali) {
      final yukseklik = _yukseklik(mekan);
      for (final parca in mekan.parcalar) {
        final cati = _halkayiYukselt(parca.dis, yukseklik);
        final delikte = parca.delikler.any((d) => _icindeMi(nokta, _halkayiYukselt(d, yukseklik)));
        if ((_icindeMi(nokta, cati) && !delikte) || _icindeMi(nokta, parca.dis)) return mekan;
      }
    }
    return null;
  }

  void _yakinlikDegisti(double yakinlik) {
    final gorunur = yakinlik >= _etiketYakinligi;
    if (_etiketlerGorunur.value == gorunur) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _etiketlerGorunur.value = gorunur;
    });
  }

  void _sec(Mekan? mekan, {bool tasi = false}) {
    setState(() => _secili = mekan);
    if (mekan != null && tasi) {
      final yakinlik = math.max(_haritaKontrolcusu.camera.zoom, _secimYakinligi);
      _haritaKontrolcusu.move(_catiMerkezi(mekan), yakinlik);
    }
  }

  void _filtreSec(MekanTuru? tur) {
    setState(() {
      _filtre = tur;
      if (_secili != null && !_filtredeMi(_secili!)) _secili = null;
    });
  }

  Future<void> _listeyiAc() async {
    final secilen = await showModalBottomSheet<Mekan>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Renkler.yuzey,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(Tema.kose * 2))),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        minChildSize: 0.35,
        maxChildSize: 0.92,
        builder: (context, kaydirma) => _BinaListesi(
          mekanlar: _listedekiMekanlar,
          seciliId: _secili?.id,
          renkler: _renkler,
          kaydirma: kaydirma,
          baslikGoster: true,
          onSec: (mekan) => Navigator.pop(context, mekan),
        ),
      ),
    );
    if (secilen != null) _sec(secilen, tasi: true);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, kisitlar) {
        final genis = kisitlar.maxWidth >= 900;
        return Scaffold(
          appBar: AppBar(
            title: Text(Moduller.harita.baslik),
            actions: [
              if (!genis && !_yukleniyor && _hata == null)
                IconButton(tooltip: 'Bina listesi', icon: const Icon(Icons.list), onPressed: _listeyiAc),
            ],
          ),
          body: _govde(genis),
        );
      },
    );
  }

  Widget _govde(bool genis) {
    if (_yukleniyor) return const Center(child: CircularProgressIndicator());

    if (_hata != null) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          BosDurum(
            ikon: Icons.cloud_off,
            baslik: 'Harita verileri yüklenemedi',
            aciklama: _hata!,
            dugmeMetni: 'Tekrar Dene',
            dugmeyeBasilinca: _yukle,
          ),
        ],
      );
    }

    final harita = Column(
      children: [
        _FiltreSatiri(
          turler: _filtreTurleri,
          secili: _filtre,
          onSec: _filtreSec,
        ),
        const Divider(),
        Expanded(child: _harita()),
      ],
    );

    if (!genis) return harita;

    return Row(
      children: [
        SizedBox(
          width: 320,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              color: Renkler.yuzey,
              border: Border(right: BorderSide(color: Renkler.kenar)),
            ),
            child: _BinaListesi(
              mekanlar: _listedekiMekanlar,
              seciliId: _secili?.id,
              renkler: _renkler,
              baslikGoster: true,
              onSec: (mekan) => _sec(mekan, tasi: true),
            ),
          ),
        ),
        Expanded(child: harita),
      ],
    );
  }

  Widget _harita() {
    final secili = _secili;
    final baslangicYakinligi = secili != null ? _secimYakinligi : _ilkYakinlik;

    return Stack(
      children: [
        FlutterMap(
          mapController: _haritaKontrolcusu,
          options: MapOptions(
            initialCenter: secili != null ? _catiMerkezi(secili) : _kampusMerkezi,
            initialZoom: baslangicYakinligi,
            minZoom: 15,
            maxZoom: 19.5,
            backgroundColor: Renkler.arka,
            cameraConstraint: CameraConstraint.containCenter(bounds: _kampusSiniri),
            interactionOptions: const InteractionOptions(flags: InteractiveFlag.all & ~InteractiveFlag.rotate),
            onTap: (_, nokta) => _sec(_dokunulanMekan(nokta)),
            onPositionChanged: (kamera, _) => _yakinlikDegisti(kamera.zoom),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.mobile',
              maxNativeZoom: 19,
            ),
            PolygonLayer(polygons: _cokgenleriGetir(), simplificationTolerance: 0, polygonCulling: false),
            ValueListenableBuilder<bool>(
              valueListenable: _etiketlerGorunur,
              builder: (context, gorunur, _) => MarkerLayer(
                markers: gorunur ? _etiketler() : const [],
              ),
            ),
            const SimpleAttributionWidget(source: Text('OpenStreetMap katkıcıları')),
          ],
        ),
        if (secili != null)
          Positioned(
            left: 12,
            right: 12,
            bottom: 32,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: _BinaKarti(mekan: secili, onKapat: () => _sec(null)),
              ),
            ),
          ),
      ],
    );
  }

  List<Marker> _etiketler() => [
        for (final mekan in _adliMekanlar)
          if (_filtredeMi(mekan))
            Marker(
              point: _catiMerkezi(mekan),
              width: 150,
              height: 40,
              child: IgnorePointer(
                child: Center(
                  child: Text(
                    mekan.ad!,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Renkler.yazi,
                      height: 1.2,
                      shadows: [
                        Shadow(color: Colors.white, blurRadius: 3),
                        Shadow(color: Colors.white, blurRadius: 6),
                      ],
                    ),
                  ),
                ),
              ),
            ),
      ];
}

class _FiltreSatiri extends StatelessWidget {
  const _FiltreSatiri({required this.turler, required this.secili, required this.onSec});

  final List<MekanTuru> turler;
  final MekanTuru? secili;
  final ValueChanged<MekanTuru?> onSec;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Renkler.yuzey,
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        children: [
          _FiltreDugmesi(metin: 'Tümü', secili: secili == null, onTap: () => onSec(null)),
          for (final tur in turler)
            _FiltreDugmesi(metin: tur.etiket, secili: secili == tur, onTap: () => onSec(tur)),
        ],
      ),
    );
  }
}

class _FiltreDugmesi extends StatelessWidget {
  const _FiltreDugmesi({required this.metin, required this.secili, required this.onTap});

  final String metin;
  final bool secili;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final sekil = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
      side: BorderSide(color: secili ? Renkler.vurgu : Renkler.kenar),
    );
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: secili ? Renkler.vurgu : Renkler.yuzey,
        shape: sekil,
        child: InkWell(
          customBorder: sekil,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Center(
              child: Text(
                metin,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: secili ? Colors.white : Renkler.yazi,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BinaKarti extends StatelessWidget {
  const _BinaKarti({required this.mekan, required this.onKapat});

  final Mekan mekan;
  final VoidCallback onKapat;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Renkler.yuzey,
      elevation: 3,
      shadowColor: const Color(0x330F2346),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Tema.kose),
        side: const BorderSide(color: Renkler.kenar),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    mekan.ad!,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Renkler.yazi),
                  ),
                ),
                IconButton(tooltip: 'Kapat', icon: const Icon(Icons.close), onPressed: onKapat),
              ],
            ),
            Rozet(metin: mekan.tur.etiket, arkaPlan: Renkler.vurguAcik, yaziRengi: Renkler.vurgu),
            const SizedBox(height: 12),
            if (mekan.derslikler.isEmpty)
              const Text('Bu binada kayıtlı derslik yok.', style: TextStyle(color: Renkler.yaziSoluk))
            else ...[
              Text(
                'Derslikler (${mekan.derslikler.length})',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Renkler.yaziSoluk),
              ),
              const SizedBox(height: 6),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 140),
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final derslik in mekan.derslikler)
                        Rozet(metin: derslik.ad, arkaPlan: Renkler.arka, yaziRengi: Renkler.yazi),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BinaListesi extends StatelessWidget {
  const _BinaListesi({
    required this.mekanlar,
    required this.seciliId,
    required this.renkler,
    required this.onSec,
    this.kaydirma,
    this.baslikGoster = false,
  });

  final List<Mekan> mekanlar;
  final int? seciliId;
  final _BinaRenkleri Function(Mekan) renkler;
  final ValueChanged<Mekan> onSec;
  final ScrollController? kaydirma;
  final bool baslikGoster;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: kaydirma,
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: mekanlar.length + (baslikGoster ? 1 : 0),
      separatorBuilder: (_, _) => const Divider(),
      itemBuilder: (context, i) {
        if (baslikGoster && i == 0) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Binalar (${mekanlar.length})',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Renkler.yazi),
            ),
          );
        }
        final mekan = mekanlar[i - (baslikGoster ? 1 : 0)];
        final secili = mekan.id == seciliId;
        return ListTile(
          selected: secili,
          selectedTileColor: Renkler.vurguAcik,
          leading: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(color: renkler(mekan).cati, borderRadius: BorderRadius.circular(3)),
          ),
          title: Text(
            mekan.ad!,
            style: TextStyle(
              fontWeight: secili ? FontWeight.w600 : FontWeight.w500,
              color: secili ? Renkler.vurgu : Renkler.yazi,
            ),
          ),
          subtitle: Text(
            mekan.derslikler.isEmpty ? mekan.tur.etiket : '${mekan.tur.etiket} · ${mekan.derslikler.length} derslik',
            style: const TextStyle(color: Renkler.yaziSoluk),
          ),
          onTap: () => onSec(mekan),
        );
      },
    );
  }
}
