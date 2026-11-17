import 'package:flutter/material.dart';

import '../../core/kutuphane_kurallari.dart';
import '../../core/moduller.dart';
import '../../core/tema.dart';
import '../../core/turkiye_saati.dart';
import '../../models/kutuphane.dart';
import '../../services/api_istemcisi.dart';
import '../../services/kutuphane_servisi.dart';
import '../../widgets/form_ogeleri.dart';
import '../../widgets/panel_ogeleri.dart';

class KutuphaneEkrani extends StatefulWidget {
  const KutuphaneEkrani({super.key});

  @override
  State<KutuphaneEkrani> createState() => _KutuphaneEkraniState();
}

class _KutuphaneEkraniState extends State<KutuphaneEkrani> {
  DateTime _simdi = TurkiyeSaati.simdi();

  KutuphaneDolulugu? _doluluk;
  List<Rezervasyon> _rezervasyonlar = [];
  bool _yukleniyor = true;
  String? _hata;

  late DateTime _gun = KutuphaneKurallari.bugun(_simdi);
  int? _baslangic;
  int? _sure;
  int? _seciliMasaId;

  List<KutuphaneMasasi> _masalar = [];
  bool _masalarYukleniyor = false;
  String? _masaHatasi;
  int _masaIstegi = 0;

  bool _kaydediliyor = false;
  String? _formHatasi;

  @override
  void initState() {
    super.initState();
    _yukle();
  }

  Future<void> _yukle() async {
    setState(() {
      _yukleniyor = _doluluk == null;
      _hata = null;
      _simdi = TurkiyeSaati.simdi();
    });
    try {
      final doluluk = await KutuphaneServisi.doluluk();
      final rezervasyonlar = await KutuphaneServisi.rezervasyonlarim();
      if (!mounted) return;
      setState(() {
        _doluluk = doluluk;
        _rezervasyonlar = rezervasyonlar;
        _yukleniyor = false;
        _secimiDuzelt();
      });
      await _masalariYukle();
    } catch (hata) {
      if (!mounted) return;
      setState(() {
        _hata = hata.toString();
        _yukleniyor = false;
      });
    }
  }

  List<DateTime> get _gunler => KutuphaneKurallari.secilebilirGunler(_simdi);

  List<int> get _baslangicSecenekleri => KutuphaneKurallari.baslangicSecenekleri(_gun, _simdi);

  int _kullanilanDakika(DateTime gun) => _rezervasyonlar
      .where((r) => KutuphaneKurallari.ayniGunMu(r.tarih, gun))
      .fold(0, (toplam, r) => toplam + r.sureDakika);

  int get _kalanDakika {
    final kalan = KutuphaneKurallari.gunlukToplamDakika - _kullanilanDakika(_gun);
    return kalan < 0 ? 0 : kalan;
  }

  List<int> get _sureSecenekleri => _baslangic == null
      ? const []
      : KutuphaneKurallari.sureSecenekleri(_baslangic!, kalanGunlukDakika: _kalanDakika);

  void _secimiDuzelt() {
    final gunler = _gunler;
    if (gunler.isEmpty) {
      _baslangic = null;
      _sure = null;
      return;
    }
    if (!gunler.any((g) => KutuphaneKurallari.ayniGunMu(g, _gun))) _gun = gunler.first;

    final baslangiclar = _baslangicSecenekleri;
    if (_baslangic == null || !baslangiclar.contains(_baslangic)) {
      _baslangic = baslangiclar.isEmpty ? null : baslangiclar.first;
    }

    final sureler = _sureSecenekleri;
    if (sureler.isEmpty) {
      _sure = null;
    } else if (_sure == null || !sureler.contains(_sure)) {
      _sure = sureler.contains(60) ? 60 : sureler.last;
    }
  }

  Future<void> _masalariYukle() async {
    final baslangic = _baslangic;
    final sure = _sure;
    final istek = ++_masaIstegi;

    if (baslangic == null || sure == null) {
      setState(() {
        _masalar = [];
        _masaHatasi = null;
        _masalarYukleniyor = false;
      });
      return;
    }

    setState(() {
      _masalarYukleniyor = true;
      _masaHatasi = null;
    });
    try {
      final masalar = await KutuphaneServisi.masalar(gun: _gun, baslangic: baslangic, sureDakika: sure);
      if (!mounted || istek != _masaIstegi) return;
      setState(() {
        _masalar = masalar;
        _masalarYukleniyor = false;
        if (!masalar.any((m) => m.id == _seciliMasaId && m.musaitMi)) _seciliMasaId = null;
      });
    } on ApiHatasi catch (hata) {
      if (!mounted || istek != _masaIstegi) return;
      setState(() {
        _masaHatasi = hata.mesaj;
        _masalar = [];
        _masalarYukleniyor = false;
      });
    }
  }

  void _secimDegisti(VoidCallback degisiklik) {
    setState(() {
      degisiklik();
      _formHatasi = null;
      _seciliMasaId = null;
      _secimiDuzelt();
    });
    _masalariYukle();
  }

  Future<void> _rezervasyonYap() async {
    final masaId = _seciliMasaId;
    final baslangic = _baslangic;
    final sure = _sure;
    if (masaId == null || baslangic == null || sure == null) return;

    final mesajci = ScaffoldMessenger.of(context);
    setState(() {
      _kaydediliyor = true;
      _formHatasi = null;
    });
    try {
      final rezervasyon = await KutuphaneServisi.rezervasyonYap(
        masaId: masaId,
        gun: _gun,
        baslangic: baslangic,
        sureDakika: sure,
      );
      mesajci.showSnackBar(SnackBar(
        content: Text('Masa ${rezervasyon.masaNo} için ${rezervasyon.saatAraligi} rezervasyonunuz oluşturuldu.'),
      ));
      _seciliMasaId = null;
      await _yukle();
    } on ApiHatasi catch (hata) {
      if (!mounted) return;
      setState(() => _formHatasi = hata.alanHatalari.values.isNotEmpty ? hata.alanHatalari.values.first : hata.mesaj);
      if (hata.durumKodu == 409) await _masalariYukle();
    } finally {
      if (mounted) setState(() => _kaydediliyor = false);
    }
  }

  Future<void> _islemYap(Rezervasyon rezervasyon, {required bool bosalt}) async {
    final onay = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(bosalt ? 'Masayı boşalt' : 'Rezervasyonu iptal et'),
        content: Text(bosalt
            ? 'Masa ${rezervasyon.masaNo} şimdi boşaltılacak. Kullandığınız süre günlük hakkınızdan düşülür.'
            : 'Masa ${rezervasyon.masaNo} için ${rezervasyon.saatAraligi} rezervasyonu iptal edilecek.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Vazgeç')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(bosalt ? 'Boşalt' : 'İptal Et'),
          ),
        ],
      ),
    );
    if (onay != true || !mounted) return;

    final mesajci = ScaffoldMessenger.of(context);
    try {
      if (bosalt) {
        await KutuphaneServisi.bosalt(rezervasyon.id);
      } else {
        await KutuphaneServisi.iptalEt(rezervasyon.id);
      }
      mesajci.showSnackBar(SnackBar(content: Text(bosalt ? 'Masa boşaltıldı.' : 'Rezervasyon iptal edildi.')));
      await _yukle();
    } on ApiHatasi catch (hata) {
      mesajci.showSnackBar(SnackBar(content: Text(hata.mesaj)));
    }
  }

  String _gunEtiketi(DateTime gun) {
    final bugun = KutuphaneKurallari.bugun(_simdi);
    final fark = gun.difference(bugun).inDays;
    if (fark == 0) return 'Bugün';
    if (fark == 1) return 'Yarın';
    return '${TurkiyeSaati.kisaGunler[gun.weekday - 1]} ${gun.day}';
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(Moduller.kutuphane.baslik),
          bottom: const TabBar(
            labelColor: Renkler.vurgu,
            unselectedLabelColor: Renkler.yaziSoluk,
            indicatorColor: Renkler.vurgu,
            labelStyle: TextStyle(fontWeight: FontWeight.w600),
            tabs: [Tab(text: 'Masa Ayır'), Tab(text: 'Rezervasyonlarım')],
          ),
        ),
        body: _govde(),
      ),
    );
  }

  Widget _govde() {
    if (_yukleniyor) return const Center(child: CircularProgressIndicator());

    if (_hata != null) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          BosDurum(
            ikon: Icons.cloud_off,
            baslik: 'Kütüphane bilgileri yüklenemedi',
            aciklama: _hata!,
            dugmeMetni: 'Tekrar Dene',
            dugmeyeBasilinca: _yukle,
          ),
        ],
      );
    }

    return TabBarView(
      children: [
        RefreshIndicator(onRefresh: _yukle, child: _masaAyirSekmesi()),
        RefreshIndicator(onRefresh: _yukle, child: _rezervasyonlarimSekmesi()),
      ],
    );
  }

  Widget _masaAyirSekmesi() {
    final doluluk = _doluluk;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (doluluk != null) _DolulukKarti(doluluk: doluluk),
                const SizedBox(height: 24),
                const BolumBasligi('Masa Ayır'),
                _secimKarti(),
                const SizedBox(height: 16),
                _masaBolumu(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _secimKarti() {
    final gunler = _gunler;
    if (gunler.isEmpty) {
      return const PanelKart(
        child: Text('Şu an rezervasyon yapılabilecek bir saat yok.', style: TextStyle(color: Renkler.yaziSoluk)),
      );
    }

    final baslangiclar = _baslangicSecenekleri;
    final sureler = _sureSecenekleri;
    final kalan = _kalanDakika;

    return PanelKart(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _AlanBasligi('Gün'),
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final gun in gunler)
                  _SecimDugmesi(
                    metin: _gunEtiketi(gun),
                    secili: KutuphaneKurallari.ayniGunMu(gun, _gun),
                    onTap: () => _secimDegisti(() => _gun = gun),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const _AlanBasligi('Başlangıç saati'),
          DropdownButtonFormField<int>(
            key: ValueKey('baslangic-${KutuphaneKurallari.tarihMetni(_gun)}-$_baslangic'),
            initialValue: _baslangic,
            isExpanded: true,
            decoration: formAlaniStili('Başlangıç', Icons.schedule),
            items: [
              for (final dakika in baslangiclar)
                DropdownMenuItem(value: dakika, child: Text(TurkiyeSaati.saatMetni(dakika))),
            ],
            onChanged: (deger) => _secimDegisti(() => _baslangic = deger),
          ),
          const SizedBox(height: 16),
          const _AlanBasligi('Süre'),
          if (sureler.isEmpty)
            const Text(
              'Bu gün için 5 saatlik rezervasyon hakkınızı doldurdunuz.',
              style: TextStyle(color: Renkler.yaziSoluk),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final sure in sureler)
                  _SecimDugmesi(
                    metin: KutuphaneKurallari.sureMetni(sure),
                    secili: sure == _sure,
                    onTap: () => _secimDegisti(() => _sure = sure),
                  ),
              ],
            ),
          const SizedBox(height: 16),
          Text(
            [
              if (_baslangic != null && _sure != null)
                'Bitiş: ${TurkiyeSaati.saatMetni(_baslangic! + _sure!)}',
              'Bu gün için kalan hakkınız: ${KutuphaneKurallari.sureMetni(kalan)}',
            ].join(' · '),
            style: const TextStyle(color: Renkler.yaziSoluk),
          ),
        ],
      ),
    );
  }

  Widget _masaBolumu() {
    if (_baslangic == null || _sure == null) return const SizedBox.shrink();

    if (_masalarYukleniyor && _masalar.isEmpty) {
      return const PanelKart(child: Center(child: CircularProgressIndicator()));
    }

    if (_masaHatasi != null) return HataKutusu(mesaj: _masaHatasi!);

    final katlar = <int, List<KutuphaneMasasi>>{};
    for (final masa in _masalar) {
      katlar.putIfAbsent(masa.kat, () => []).add(masa);
    }
    final secili = _masalar.where((m) => m.id == _seciliMasaId).toList();
    final musaitSayisi = _masalar.where((m) => m.musaitMi).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '$musaitSayisi masa müsait',
                style: const TextStyle(fontWeight: FontWeight.w600, color: Renkler.yazi),
              ),
            ),
            const _Aciklama(ikon: Icons.power_outlined, metin: 'Priz'),
            const SizedBox(width: 12),
            const _Aciklama(ikon: Icons.groups_outlined, metin: 'Grup masası'),
          ],
        ),
        const SizedBox(height: 12),
        for (final girdi in katlar.entries) ...[
          Text(
            '${girdi.key}. Kat',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Renkler.yaziSoluk),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final masa in girdi.value)
                _MasaKutusu(
                  masa: masa,
                  secili: masa.id == _seciliMasaId,
                  onTap: masa.musaitMi
                      ? () => setState(() {
                            _seciliMasaId = masa.id;
                            _formHatasi = null;
                          })
                      : null,
                ),
            ],
          ),
          const SizedBox(height: 16),
        ],
        if (_formHatasi != null) ...[
          HataKutusu(mesaj: _formHatasi!),
          const SizedBox(height: 12),
        ],
        if (secili.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Masa ${secili.first.masaNo} · ${_gunEtiketi(_gun)} '
              '${TurkiyeSaati.saatMetni(_baslangic!)}–${TurkiyeSaati.saatMetni(_baslangic! + _sure!)}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600, color: Renkler.vurgu),
            ),
          ),
        if (secili.isEmpty)
          const ElevatedButton(
            onPressed: null,
            child: Text('Bir masa seçin', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          )
        else
          AnaButon(metin: 'Rezervasyon Yap', yukleniyor: _kaydediliyor, onPressed: _rezervasyonYap),
      ],
    );
  }

  Widget _rezervasyonlarimSekmesi() {
    final bugun = KutuphaneKurallari.bugun(_simdi);
    final aktifler = _rezervasyonlar.where((r) => r.durum != RezervasyonDurumu.tamamlandi).toList();
    final tamamlananlar = _rezervasyonlar.where((r) => r.durum == RezervasyonDurumu.tamamlandi).toList();

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        SayfaBasligi(
          baslik: 'Rezervasyonlarım',
          aciklama: 'Bugün kullandığınız süre: ${KutuphaneKurallari.sureMetni(_kullanilanDakika(bugun))} / 5 sa',
        ),
        if (_rezervasyonlar.isEmpty)
          const BosDurum(
            ikon: Icons.event_seat_outlined,
            baslik: 'Rezervasyonunuz yok',
            aciklama: 'Masa Ayır sekmesinden gün, saat ve süre seçerek masa ayırabilirsiniz.',
          )
        else ...[
          for (final rezervasyon in aktifler) ...[
            _RezervasyonKarti(
              rezervasyon: rezervasyon,
              gunEtiketi: _gunEtiketi(rezervasyon.tarih),
              onIptal: rezervasyon.durum == RezervasyonDurumu.yaklasan
                  ? () => _islemYap(rezervasyon, bosalt: false)
                  : null,
              onBosalt: rezervasyon.durum == RezervasyonDurumu.devamEdiyor
                  ? () => _islemYap(rezervasyon, bosalt: true)
                  : null,
            ),
            const SizedBox(height: 12),
          ],
          if (tamamlananlar.isNotEmpty) ...[
            const SizedBox(height: 8),
            const BolumBasligi('Bugün tamamlananlar'),
            for (final rezervasyon in tamamlananlar) ...[
              _RezervasyonKarti(rezervasyon: rezervasyon, gunEtiketi: _gunEtiketi(rezervasyon.tarih)),
              const SizedBox(height: 12),
            ],
          ],
        ],
      ],
    );
  }
}

class _DolulukKarti extends StatelessWidget {
  const _DolulukKarti({required this.doluluk});

  final KutuphaneDolulugu doluluk;

  @override
  Widget build(BuildContext context) {
    return PanelKart(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'ANLIK DOLULUK',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.6, color: Renkler.yaziSoluk),
                ),
              ),
              Rozet(metin: 'Saat ${doluluk.saat}', arkaPlan: Renkler.arka, yaziRengi: Renkler.yaziSoluk),
            ],
          ),
          const SizedBox(height: 12),
          if (!doluluk.acikMi)
            const Text(
              'Kütüphane şu an kapalı. Açık olduğu saatler 08:00–22:00.',
              style: TextStyle(color: Renkler.yazi),
            )
          else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '%${doluluk.oran}',
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: Renkler.vurgu, height: 1),
                ),
                const SizedBox(width: 12),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    '${doluluk.doluMasa} / ${doluluk.toplamMasa} masa dolu',
                    style: const TextStyle(color: Renkler.yaziSoluk),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _Cubuk(oran: doluluk.toplamMasa == 0 ? 0 : doluluk.doluMasa / doluluk.toplamMasa, yukseklik: 8),
            const SizedBox(height: 16),
            for (final kat in doluluk.katlar)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    SizedBox(width: 56, child: Text('${kat.kat}. Kat', style: const TextStyle(fontSize: 13))),
                    Expanded(child: _Cubuk(oran: kat.toplam == 0 ? 0 : kat.dolu / kat.toplam, yukseklik: 6)),
                    SizedBox(
                      width: 56,
                      child: Text(
                        '${kat.dolu}/${kat.toplam}',
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontSize: 13, color: Renkler.yaziSoluk),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _Cubuk extends StatelessWidget {
  const _Cubuk({required this.oran, required this.yukseklik});

  final double oran;
  final double yukseklik;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(yukseklik),
      child: LinearProgressIndicator(
        value: oran,
        minHeight: yukseklik,
        color: Renkler.vurgu,
        backgroundColor: Renkler.vurguAcik,
      ),
    );
  }
}

class _AlanBasligi extends StatelessWidget {
  const _AlanBasligi(this.metin);

  final String metin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(metin, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Renkler.yaziSoluk)),
    );
  }
}

class _SecimDugmesi extends StatelessWidget {
  const _SecimDugmesi({required this.metin, required this.secili, required this.onTap});

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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
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
    );
  }
}

class _Aciklama extends StatelessWidget {
  const _Aciklama({required this.ikon, required this.metin});

  final IconData ikon;
  final String metin;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(ikon, size: 14, color: Renkler.yaziSoluk),
        const SizedBox(width: 4),
        Text(metin, style: const TextStyle(fontSize: 12, color: Renkler.yaziSoluk)),
      ],
    );
  }
}

class _MasaKutusu extends StatelessWidget {
  const _MasaKutusu({required this.masa, required this.secili, required this.onTap});

  final KutuphaneMasasi masa;
  final bool secili;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final musait = masa.musaitMi;
    final arkaPlan = secili ? Renkler.vurgu : (musait ? Renkler.yuzey : Renkler.arka);
    final yazi = secili ? Colors.white : (musait ? Renkler.yazi : Renkler.yaziSoluk);
    final sekil = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(Tema.kose),
      side: BorderSide(color: secili ? Renkler.vurgu : Renkler.kenar),
    );

    return SizedBox(
      width: 76,
      height: 64,
      child: Material(
        color: arkaPlan,
        shape: sekil,
        child: InkWell(
          customBorder: sekil,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(masa.masaNo, style: TextStyle(fontWeight: FontWeight.w600, color: yazi)),
                const SizedBox(height: 4),
                if (!musait)
                  Text('Dolu', style: TextStyle(fontSize: 11, color: yazi))
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (masa.prizVarMi) Icon(Icons.power_outlined, size: 14, color: yazi),
                      if (masa.kapasite > 1) ...[
                        const SizedBox(width: 2),
                        Icon(Icons.groups_outlined, size: 14, color: yazi),
                      ],
                      if (!masa.prizVarMi && masa.kapasite <= 1) Text('Müsait', style: TextStyle(fontSize: 11, color: yazi)),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RezervasyonKarti extends StatelessWidget {
  const _RezervasyonKarti({required this.rezervasyon, required this.gunEtiketi, this.onIptal, this.onBosalt});

  final Rezervasyon rezervasyon;
  final String gunEtiketi;
  final VoidCallback? onIptal;
  final VoidCallback? onBosalt;

  @override
  Widget build(BuildContext context) {
    final durum = rezervasyon.durum;
    final rozet = switch (durum) {
      RezervasyonDurumu.devamEdiyor => Rozet(metin: durum.etiket, arkaPlan: Renkler.vurgu, yaziRengi: Colors.white),
      RezervasyonDurumu.yaklasan => Rozet(metin: durum.etiket, arkaPlan: Renkler.vurguAcik, yaziRengi: Renkler.vurgu),
      RezervasyonDurumu.tamamlandi => Rozet(metin: durum.etiket, arkaPlan: Renkler.arka, yaziRengi: Renkler.yaziSoluk),
    };

    return PanelKart(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: Renkler.vurguAcik, borderRadius: BorderRadius.circular(Tema.kose)),
            child: const Icon(Icons.event_seat_outlined, color: Renkler.vurgu),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Masa ${rezervasyon.masaNo}',
                      style: const TextStyle(fontWeight: FontWeight.w600, color: Renkler.yazi),
                    ),
                    rozet,
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$gunEtiketi · ${rezervasyon.saatAraligi} · ${rezervasyon.kat}. Kat',
                  style: const TextStyle(color: Renkler.yaziSoluk),
                ),
              ],
            ),
          ),
          if (onIptal != null) TextButton(onPressed: onIptal, child: const Text('İptal Et')),
          if (onBosalt != null) OutlinedButton(onPressed: onBosalt, child: const Text('Boşalt')),
        ],
      ),
    );
  }
}
