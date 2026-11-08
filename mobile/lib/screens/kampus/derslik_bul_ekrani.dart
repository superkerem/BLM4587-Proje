import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/moduller.dart';
import '../../core/tema.dart';
import '../../core/turkiye_saati.dart';
import '../../models/ders_programi.dart';
import '../../services/api_istemcisi.dart';
import '../../services/kampus_servisi.dart';
import '../../widgets/panel_ogeleri.dart';
import 'ders_secim_sayfasi.dart';

void _haritadaGoster(BuildContext context, int mekanId) {
  Navigator.pushNamed(context, '/kampus/harita', arguments: mekanId);
}

class DerslikBulEkrani extends StatefulWidget {
  const DerslikBulEkrani({super.key});

  @override
  State<DerslikBulEkrani> createState() => _DerslikBulEkraniState();
}

class _DerslikBulEkraniState extends State<DerslikBulEkrani> {
  DersProgrami? _program;
  Set<String> _derslerim = {};
  List<Sinav> _sinavlar = [];
  bool _yukleniyor = true;
  bool _kaydediliyor = false;
  String? _hata;
  DateTime _simdi = TurkiyeSaati.simdi();
  Timer? _zamanlayici;

  @override
  void initState() {
    super.initState();
    _yukle();
    _zamanlayici = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() => _simdi = TurkiyeSaati.simdi());
    });
  }

  @override
  void dispose() {
    _zamanlayici?.cancel();
    super.dispose();
  }

  Future<void> _yukle() async {
    setState(() {
      _yukleniyor = true;
      _hata = null;
    });
    try {
      final program = await KampusServisi.dersProgrami();
      final derslerim = await KampusServisi.derslerim();
      final sinavlar = await KampusServisi.sinavlarim();
      if (!mounted) return;
      setState(() {
        _program = program;
        _derslerim = derslerim;
        _sinavlar = sinavlar;
        _simdi = TurkiyeSaati.simdi();
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

  Future<void> _kaydet(Set<String> kodlar) async {
    final mesajci = ScaffoldMessenger.of(context);
    setState(() => _kaydediliyor = true);
    try {
      final kaydedilen = await KampusServisi.derslerimiKaydet(kodlar);
      final sinavlar = await KampusServisi.sinavlarim();
      if (!mounted) return;
      setState(() {
        _derslerim = kaydedilen;
        _sinavlar = sinavlar;
      });
    } on ApiHatasi catch (hata) {
      mesajci.showSnackBar(SnackBar(content: Text(hata.mesaj)));
    } finally {
      if (mounted) setState(() => _kaydediliyor = false);
    }
  }

  Future<void> _dersSec() async {
    final program = _program;
    if (program == null) return;
    final sonuc = await dersSecimSayfasiniAc(context, program, _derslerim);
    if (sonuc != null) await _kaydet(sonuc);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(Moduller.derslikBul.baslik),
          bottom: const TabBar(
            labelColor: Renkler.vurgu,
            unselectedLabelColor: Renkler.yaziSoluk,
            indicatorColor: Renkler.vurgu,
            labelStyle: TextStyle(fontWeight: FontWeight.w600),
            tabs: [Tab(text: 'Programım'), Tab(text: 'Boş Derslikler')],
          ),
        ),
        body: _govde(),
      ),
    );
  }

  Widget _govde() {
    if (_yukleniyor) return const Center(child: CircularProgressIndicator());

    final program = _program;
    if (_hata != null || program == null) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          BosDurum(
            ikon: Icons.cloud_off,
            baslik: 'Ders programı yüklenemedi',
            aciklama: _hata ?? '',
            dugmeMetni: 'Tekrar Dene',
            dugmeyeBasilinca: _yukle,
          ),
        ],
      );
    }

    return TabBarView(
      children: [
        RefreshIndicator(
          onRefresh: _yukle,
          child: _ProgramimSekmesi(
            program: program,
            derslerim: _derslerim,
            sinavlar: _sinavlar,
            simdi: _simdi,
            kaydediliyor: _kaydediliyor,
            onDersSec: _dersSec,
            onDersKaldir: (kod) => _kaydet(_derslerim.difference({kod})),
          ),
        ),
        RefreshIndicator(
          onRefresh: _yukle,
          child: _BosDersliklerSekmesi(program: program, simdi: _simdi),
        ),
      ],
    );
  }
}

class _ProgramimSekmesi extends StatefulWidget {
  const _ProgramimSekmesi({
    required this.program,
    required this.derslerim,
    required this.sinavlar,
    required this.simdi,
    required this.kaydediliyor,
    required this.onDersSec,
    required this.onDersKaldir,
  });

  final DersProgrami program;
  final Set<String> derslerim;
  final List<Sinav> sinavlar;
  final DateTime simdi;
  final bool kaydediliyor;
  final VoidCallback onDersSec;
  final ValueChanged<String> onDersKaldir;

  @override
  State<_ProgramimSekmesi> createState() => _ProgramimSekmesiState();
}

class _ProgramimSekmesiState extends State<_ProgramimSekmesi> {
  late int _seciliGun = widget.simdi.weekday <= 5 ? widget.simdi.weekday : 1;

  Ders? _suAnkiDers(List<Ders> oturumlar) {
    for (final ders in oturumlar) {
      if (ders.devamEdiyorMu(widget.simdi)) return ders;
    }
    return null;
  }

  (Ders, int)? _siradakiDers(List<Ders> oturumlar) {
    final bugun = widget.simdi.weekday;
    final dakika = TurkiyeSaati.dakika(widget.simdi);
    for (var fark = 0; fark <= 7; fark++) {
      final gun = (bugun - 1 + fark) % 7 + 1;
      final adaylar = oturumlar.where((d) => d.gun == gun && (fark > 0 || d.baslangic > dakika)).toList()
        ..sort((a, b) => a.baslangic.compareTo(b.baslangic));
      if (adaylar.isNotEmpty) return (adaylar.first, fark);
    }
    return null;
  }

  String _gunMetni(int fark, int gun) => switch (fark) {
        0 => 'Bugün',
        1 => 'Yarın',
        _ => TurkceTarih.gunler[gun - 1],
      };

  @override
  Widget build(BuildContext context) {
    final oturumlar = widget.program.oturumlar(widget.derslerim);

    return LayoutBuilder(
      builder: (context, kisitlar) {
        final genis = kisitlar.maxWidth >= 720;
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            _DerslerimKarti(
              program: widget.program,
              derslerim: widget.derslerim,
              kaydediliyor: widget.kaydediliyor,
              onDersSec: widget.onDersSec,
              onDersKaldir: widget.onDersKaldir,
            ),
            const SizedBox(height: 16),
            if (widget.derslerim.isEmpty)
              BosDurum(
                ikon: Icons.event_note_outlined,
                baslik: 'Programın henüz boş',
                aciklama: 'Aldığın dersleri seç; haftalık programın, derslerin nerede olduğu ve sınavların burada görünsün.',
                dugmeMetni: 'Ders seç',
                dugmeyeBasilinca: widget.onDersSec,
              )
            else ...[
              _durumKartlari(oturumlar, genis),
              const SizedBox(height: 24),
              const BolumBasligi('Haftalık Program'),
              if (genis)
                _HaftalikCizelge(program: widget.program, oturumlar: oturumlar, simdi: widget.simdi)
              else
                _gunlukListe(oturumlar),
              const SizedBox(height: 24),
              const BolumBasligi('Yaklaşan Sınavlar'),
              _SinavListesi(sinavlar: widget.sinavlar, program: widget.program),
            ],
          ],
        );
      },
    );
  }

  Widget _durumKartlari(List<Ders> oturumlar, bool genis) {
    final suAn = _suAnkiDers(oturumlar);
    final siradaki = _siradakiDers(oturumlar);

    final suAnKarti = _DurumKarti(
      baslik: 'Şu an',
      ders: suAn,
      program: widget.program,
      zamanMetni: suAn == null ? null : 'Bitiş ${TurkiyeSaati.saatMetni(suAn.bitis)}',
      bosMetin: 'Şu an devam eden dersin yok.',
    );
    final siradakiKarti = _DurumKarti(
      baslik: 'Sıradaki',
      ders: siradaki?.$1,
      program: widget.program,
      zamanMetni: siradaki == null
          ? null
          : '${_gunMetni(siradaki.$2, siradaki.$1.gun)} ${TurkiyeSaati.saatMetni(siradaki.$1.baslangic)}',
      bosMetin: 'Bu hafta başka dersin yok.',
    );

    if (!genis) {
      return Column(children: [suAnKarti, const SizedBox(height: 12), siradakiKarti]);
    }
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: suAnKarti),
          const SizedBox(width: 12),
          Expanded(child: siradakiKarti),
        ],
      ),
    );
  }

  Widget _gunlukListe(List<Ders> oturumlar) {
    final gunun = oturumlar.where((d) => d.gun == _seciliGun).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            for (var gun = 1; gun <= 5; gun++) ...[
              if (gun > 1) const SizedBox(width: 6),
              Expanded(
                child: _GunDugmesi(
                  metin: TurkiyeSaati.kisaGunler[gun - 1],
                  secili: gun == _seciliGun,
                  bugunMu: gun == widget.simdi.weekday,
                  onTap: () => setState(() => _seciliGun = gun),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        if (gunun.isEmpty)
          const PanelKart(
            child: Text('Bu gün dersin yok.', style: TextStyle(color: Renkler.yaziSoluk)),
          )
        else
          PanelKart(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < gunun.length; i++) ...[
                  if (i > 0) const Divider(),
                  _DersSatiri(
                    ders: gunun[i],
                    program: widget.program,
                    devamEdiyor: gunun[i].devamEdiyorMu(widget.simdi),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _DerslerimKarti extends StatelessWidget {
  const _DerslerimKarti({
    required this.program,
    required this.derslerim,
    required this.kaydediliyor,
    required this.onDersSec,
    required this.onDersKaldir,
  });

  final DersProgrami program;
  final Set<String> derslerim;
  final bool kaydediliyor;
  final VoidCallback onDersSec;
  final ValueChanged<String> onDersKaldir;

  @override
  Widget build(BuildContext context) {
    final sirali = derslerim.toList()..sort();

    return PanelKart(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Derslerim',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Renkler.yazi),
                ),
              ),
              if (kaydediliyor)
                const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                ),
              OutlinedButton.icon(
                onPressed: kaydediliyor ? null : onDersSec,
                icon: Icon(derslerim.isEmpty ? Icons.add : Icons.edit_outlined, size: 18),
                label: Text(derslerim.isEmpty ? 'Ders seç' : 'Düzenle'),
              ),
            ],
          ),
          if (sirali.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text('Henüz ders seçmedin.', style: TextStyle(color: Renkler.yaziSoluk)),
            )
          else ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final kod in sirali)
                  _DersEtiketi(
                    metin: program.etiket(kod),
                    onKaldir: kaydediliyor ? null : () => onDersKaldir(kod),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _DersEtiketi extends StatelessWidget {
  const _DersEtiketi({required this.metin, required this.onKaldir});

  final String metin;
  final VoidCallback? onKaldir;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 320),
      padding: const EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        color: Renkler.vurguAcik,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              metin,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Renkler.vurgu),
            ),
          ),
          InkWell(
            onTap: onKaldir,
            borderRadius: BorderRadius.circular(6),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 5),
              child: Icon(Icons.close, size: 16, color: Renkler.vurgu),
            ),
          ),
        ],
      ),
    );
  }
}

String _derslikMetni(DersProgrami program, int? derslikId) {
  final derslik = program.derslik(derslikId);
  if (derslik == null) return 'Derslik belirtilmemiş';
  return '${derslik.ad} · ${derslik.konumMetni}';
}

class _DurumKarti extends StatelessWidget {
  const _DurumKarti({
    required this.baslik,
    required this.ders,
    required this.program,
    required this.zamanMetni,
    required this.bosMetin,
  });

  final String baslik;
  final Ders? ders;
  final DersProgrami program;
  final String? zamanMetni;
  final String bosMetin;

  @override
  Widget build(BuildContext context) {
    final ders = this.ders;
    final mekanId = program.derslik(ders?.derslikId)?.mekanId;

    return PanelKart(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                baslik.toUpperCase(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                  color: Renkler.yaziSoluk,
                ),
              ),
              const Spacer(),
              if (zamanMetni != null)
                Rozet(metin: zamanMetni!, arkaPlan: Renkler.vurguAcik, yaziRengi: Renkler.vurgu),
            ],
          ),
          const SizedBox(height: 10),
          if (ders == null)
            Text(bosMetin, style: const TextStyle(color: Renkler.yaziSoluk))
          else ...[
            Text(
              program.etiket(ders.kod),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Renkler.yazi),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.place_outlined, size: 16, color: Renkler.yaziSoluk),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _derslikMetni(program, ders.derslikId),
                    style: const TextStyle(color: Renkler.yaziSoluk),
                  ),
                ),
              ],
            ),
            if (mekanId != null) ...[
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => _haritadaGoster(context, mekanId),
                icon: const Icon(Icons.map_outlined, size: 18),
                label: const Text('Haritada göster'),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _GunDugmesi extends StatelessWidget {
  const _GunDugmesi({required this.metin, required this.secili, required this.bugunMu, required this.onTap});

  final String metin;
  final bool secili;
  final bool bugunMu;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final sekil = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(Tema.kose),
      side: BorderSide(color: secili ? Renkler.vurgu : Renkler.kenar),
    );
    return Material(
      color: secili ? Renkler.vurgu : Renkler.yuzey,
      shape: sekil,
      child: InkWell(
        customBorder: sekil,
        onTap: onTap,
        child: SizedBox(
          height: 40,
          child: Center(
            child: Text(
              metin,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: secili ? Colors.white : (bugunMu ? Renkler.vurgu : Renkler.yazi),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DersSatiri extends StatelessWidget {
  const _DersSatiri({required this.ders, required this.program, required this.devamEdiyor});

  final Ders ders;
  final DersProgrami program;
  final bool devamEdiyor;

  @override
  Widget build(BuildContext context) {
    final mekanId = program.derslik(ders.derslikId)?.mekanId;
    final ad = program.dersAdi(ders.kod);

    return Container(
      decoration: BoxDecoration(
        color: devamEdiyor ? Renkler.vurguAcik : null,
        border: devamEdiyor ? const Border(left: BorderSide(color: Renkler.vurgu, width: 3)) : null,
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 52,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  TurkiyeSaati.saatMetni(ders.baslangic),
                  style: const TextStyle(fontWeight: FontWeight.w600, color: Renkler.yazi),
                ),
                Text(
                  TurkiyeSaati.saatMetni(ders.bitis),
                  style: const TextStyle(fontSize: 12, color: Renkler.yaziSoluk),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(ders.kod, style: const TextStyle(fontWeight: FontWeight.w600, color: Renkler.yazi)),
                    if (ders.labMi)
                      const Rozet(metin: 'Lab', arkaPlan: Renkler.arka, yaziRengi: Renkler.yaziSoluk),
                    if (devamEdiyor)
                      const Rozet(metin: 'Devam ediyor', arkaPlan: Renkler.vurgu, yaziRengi: Colors.white),
                  ],
                ),
                if (ad != ders.kod) ...[
                  const SizedBox(height: 2),
                  Text(ad, style: const TextStyle(color: Renkler.yazi)),
                ],
                const SizedBox(height: 4),
                Text(
                  _derslikMetni(program, ders.derslikId),
                  style: const TextStyle(fontSize: 13, color: Renkler.yaziSoluk),
                ),
              ],
            ),
          ),
          if (mekanId != null)
            IconButton(
              tooltip: 'Haritada göster',
              icon: const Icon(Icons.map_outlined, color: Renkler.vurgu),
              onPressed: () => _haritadaGoster(context, mekanId),
            ),
        ],
      ),
    );
  }
}

class _HaftalikCizelge extends StatelessWidget {
  const _HaftalikCizelge({required this.program, required this.oturumlar, required this.simdi});

  final DersProgrami program;
  final List<Ders> oturumlar;
  final DateTime simdi;

  static const _ilkSaat = 8;
  static const _sonSaat = 19;
  static const _saatYuksekligi = 56.0;

  double _konum(int dakika) => (dakika - _ilkSaat * 60) / 60 * _saatYuksekligi;

  @override
  Widget build(BuildContext context) {
    const toplamYukseklik = (_sonSaat - _ilkSaat) * _saatYuksekligi;

    return PanelKart(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(width: 44),
              for (var gun = 1; gun <= 5; gun++)
                Expanded(
                  child: Center(
                    child: Text(
                      TurkceTarih.gunler[gun - 1],
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: gun == simdi.weekday ? Renkler.vurgu : Renkler.yazi,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: toplamYukseklik,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 44,
                  child: Stack(
                    children: [
                      for (var saat = _ilkSaat; saat < _sonSaat; saat++)
                        Positioned(
                          top: _konum(saat * 60),
                          left: 0,
                          child: Text(
                            '${saat.toString().padLeft(2, '0')}:00',
                            style: const TextStyle(fontSize: 11, color: Renkler.yaziSoluk),
                          ),
                        ),
                    ],
                  ),
                ),
                for (var gun = 1; gun <= 5; gun++) Expanded(child: _gunSutunu(gun)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _gunSutunu(int gun) {
    final dersler = oturumlar.where((d) => d.gun == gun).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: gun == simdi.weekday ? Renkler.arka : null,
        border: const Border(left: BorderSide(color: Renkler.kenar)),
      ),
      child: Stack(
        children: [
          for (var saat = _ilkSaat; saat < _sonSaat; saat++)
            Positioned(
              top: _konum(saat * 60),
              left: 0,
              right: 0,
              child: const Divider(),
            ),
          for (final ders in dersler)
            Positioned(
              top: _konum(ders.baslangic),
              height: _konum(ders.bitis) - _konum(ders.baslangic),
              left: 3,
              right: 3,
              child: _CizelgeBlogu(
                ders: ders,
                program: program,
                devamEdiyor: ders.devamEdiyorMu(simdi),
              ),
            ),
        ],
      ),
    );
  }
}

class _CizelgeBlogu extends StatelessWidget {
  const _CizelgeBlogu({required this.ders, required this.program, required this.devamEdiyor});

  final Ders ders;
  final DersProgrami program;
  final bool devamEdiyor;

  @override
  Widget build(BuildContext context) {
    final yazi = devamEdiyor ? Colors.white : Renkler.vurgu;
    final derslik = program.derslik(ders.derslikId);

    return Tooltip(
      message: '${program.etiket(ders.kod)}\n${ders.saatAraligi}\n${_derslikMetni(program, ders.derslikId)}',
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: devamEdiyor ? Renkler.vurguKoyu : Renkler.vurguAcik,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: devamEdiyor ? Renkler.vurguKoyu : const Color(0xFFC6D6E8)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ders.labMi ? '${ders.kod} · Lab' : ders.kod,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: yazi),
            ),
            Text(
              ders.saatAraligi,
              maxLines: 1,
              overflow: TextOverflow.clip,
              style: TextStyle(fontSize: 11, color: yazi),
            ),
            if (derslik != null)
              Flexible(
                child: Text(
                  derslik.ad,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: yazi),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SinavListesi extends StatelessWidget {
  const _SinavListesi({required this.sinavlar, required this.program});

  final List<Sinav> sinavlar;
  final DersProgrami program;

  @override
  Widget build(BuildContext context) {
    if (sinavlar.isEmpty) {
      return const PanelKart(
        child: Row(
          children: [
            Icon(Icons.event_busy_outlined, color: Renkler.yaziSoluk),
            SizedBox(width: 10),
            Expanded(child: Text('Sınav takvimi henüz eklenmedi.', style: TextStyle(color: Renkler.yaziSoluk))),
          ],
        ),
      );
    }

    return PanelKart(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < sinavlar.length; i++) ...[
            if (i > 0) const Divider(),
            _SinavSatiri(sinav: sinavlar[i], program: program),
          ],
        ],
      ),
    );
  }
}

class _SinavSatiri extends StatelessWidget {
  const _SinavSatiri({required this.sinav, required this.program});

  final Sinav sinav;
  final DersProgrami program;

  @override
  Widget build(BuildContext context) {
    final yer = sinav.derslikAdi == null
        ? 'Derslik belirtilmemiş'
        : (sinav.mekanAdi == null ? sinav.derslikAdi! : '${sinav.derslikAdi} · ${sinav.mekanAdi}');
    final mekanId = sinav.mekanId;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Rozet(metin: sinav.tur.etiket, arkaPlan: Renkler.vurgu, yaziRengi: Colors.white),
                    Text(
                      program.etiket(sinav.dersKodu),
                      style: const TextStyle(fontWeight: FontWeight.w600, color: Renkler.yazi),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${TurkceTarih.uzun(sinav.tarih)} · '
                  '${TurkiyeSaati.saatMetni(sinav.baslangic)}–${TurkiyeSaati.saatMetni(sinav.bitis)}',
                  style: const TextStyle(color: Renkler.yazi),
                ),
                Text(yer, style: const TextStyle(fontSize: 13, color: Renkler.yaziSoluk)),
              ],
            ),
          ),
          if (mekanId != null)
            IconButton(
              tooltip: 'Haritada göster',
              icon: const Icon(Icons.map_outlined, color: Renkler.vurgu),
              onPressed: () => _haritadaGoster(context, mekanId),
            ),
        ],
      ),
    );
  }
}

class _BosDerslik {
  const _BosDerslik(this.derslik, this.sonrakiDers);

  final Derslik derslik;
  final int? sonrakiDers;
}

class _BosDersliklerSekmesi extends StatelessWidget {
  const _BosDersliklerSekmesi({required this.program, required this.simdi});

  final DersProgrami program;
  final DateTime simdi;

  List<_BosDerslik> _bosDerslikler() {
    final gun = simdi.weekday;
    final dakika = TurkiyeSaati.dakika(simdi);
    final sonuc = <_BosDerslik>[];

    for (final derslik in program.derslikler.where((d) => d.kampusteMi)) {
      final bugunku = program.dersler.where((d) => d.derslikId == derslik.id && d.gun == gun).toList();
      if (bugunku.any((d) => d.baslangic <= dakika && dakika < d.bitis)) continue;

      final sonrakiler = bugunku.where((d) => d.baslangic > dakika).map((d) => d.baslangic).toList()..sort();
      sonuc.add(_BosDerslik(derslik, sonrakiler.isEmpty ? null : sonrakiler.first));
    }

    sonuc.sort((a, b) {
      if (a.sonrakiDers == null && b.sonrakiDers == null) return a.derslik.ad.compareTo(b.derslik.ad);
      if (a.sonrakiDers == null) return -1;
      if (b.sonrakiDers == null) return 1;
      return b.sonrakiDers!.compareTo(a.sonrakiDers!);
    });
    return sonuc;
  }

  @override
  Widget build(BuildContext context) {
    final bosDerslikler = _bosDerslikler();
    final saat = TurkiyeSaati.saatMetni(TurkiyeSaati.dakika(simdi));

    return LayoutBuilder(
      builder: (context, kisitlar) {
        final sutun = kisitlar.maxWidth >= 720 ? 2 : 1;
        final kartGenisligi = (kisitlar.maxWidth - 32 - (sutun - 1) * 12) / sutun;

        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            SayfaBasligi(
              baslik: 'Şu an boş derslikler',
              aciklama: '${TurkceTarih.gunler[simdi.weekday - 1]} $saat itibarıyla ${bosDerslikler.length} derslik boş.',
            ),
            if (bosDerslikler.isEmpty)
              const BosDurum(
                ikon: Icons.meeting_room_outlined,
                baslik: 'Şu an boş derslik yok',
                aciklama: 'Kampüsteki tüm derslikler şu an derste.',
              )
            else
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final bos in bosDerslikler)
                    SizedBox(width: kartGenisligi, child: _BosDerslikKarti(bos: bos)),
                ],
              ),
          ],
        );
      },
    );
  }
}

class _BosDerslikKarti extends StatelessWidget {
  const _BosDerslikKarti({required this.bos});

  final _BosDerslik bos;

  @override
  Widget build(BuildContext context) {
    final derslik = bos.derslik;
    final sonraki = bos.sonrakiDers;
    final mekanId = derslik.mekanId;

    return PanelKart(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: Renkler.vurguAcik, borderRadius: BorderRadius.circular(Tema.kose)),
            child: const Icon(Icons.meeting_room_outlined, color: Renkler.vurgu),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(derslik.ad, style: const TextStyle(fontWeight: FontWeight.w600, color: Renkler.yazi)),
                Text(derslik.konumMetni, style: const TextStyle(fontSize: 13, color: Renkler.yaziSoluk)),
                const SizedBox(height: 6),
                sonraki == null
                    ? const Rozet(metin: 'Bugün boş', arkaPlan: Renkler.vurguAcik, yaziRengi: Renkler.vurgu)
                    : Rozet(
                        metin: 'Sonraki ders ${TurkiyeSaati.saatMetni(sonraki)}',
                        arkaPlan: Renkler.arka,
                        yaziRengi: Renkler.yaziSoluk,
                      ),
              ],
            ),
          ),
          if (mekanId != null)
            TextButton.icon(
              onPressed: () => _haritadaGoster(context, mekanId),
              icon: const Icon(Icons.map_outlined, size: 18),
              label: const Text('Haritada göster'),
            ),
        ],
      ),
    );
  }
}
