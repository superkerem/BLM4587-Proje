import 'package:flutter/material.dart';

import '../../core/tema.dart';
import '../../models/ders_programi.dart';
import '../../widgets/form_ogeleri.dart';

const _grupSirasi = [
  'Türkçe 1. Sınıf',
  'Türkçe 2. Sınıf',
  'Türkçe 3. Sınıf',
  'Türkçe 4. Sınıf',
  'İngilizce 1. Sınıf',
  'İngilizce 2. Sınıf',
  'İngilizce 3. Sınıf',
  'İngilizce 4. Sınıf',
];

Future<Set<String>?> dersSecimSayfasiniAc(BuildContext context, DersProgrami program, Set<String> secili) {
  return showModalBottomSheet<Set<String>>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Renkler.yuzey,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(Tema.kose * 2))),
    builder: (context) => DersSecimSayfasi(program: program, baslangicSecimi: secili),
  );
}

class DersSecimSayfasi extends StatefulWidget {
  const DersSecimSayfasi({super.key, required this.program, required this.baslangicSecimi});

  final DersProgrami program;
  final Set<String> baslangicSecimi;

  @override
  State<DersSecimSayfasi> createState() => _DersSecimSayfasiState();
}

class _DersSecimSayfasiState extends State<DersSecimSayfasi> {
  final _aramaController = TextEditingController();
  late final Set<String> _secili = {...widget.baslangicSecimi};
  final Set<String> _acikGruplar = {};
  final Set<String> _aramadaKapatilanlar = {};
  String _arama = '';

  late final Map<String, List<DersSecenegi>> _gruplar = _gruplariOlustur();

  @override
  void dispose() {
    _aramaController.dispose();
    super.dispose();
  }

  Map<String, List<DersSecenegi>> _gruplariOlustur() {
    final gruplar = <String, List<DersSecenegi>>{};
    for (final grup in _grupSirasi) {
      gruplar[grup] = [];
    }
    for (final secenek in widget.program.secenekler) {
      gruplar.putIfAbsent(secenek.grup, () => []).add(secenek);
    }
    gruplar.removeWhere((_, dersler) => dersler.isEmpty);
    return gruplar;
  }

  static String _kucult(String metin) =>
      metin.replaceAll('İ', 'i').replaceAll('I', 'ı').toLowerCase().trim();

  bool _eslesiyorMu(DersSecenegi ders) {
    final aranan = _kucult(_arama);
    return _kucult(ders.kod).contains(aranan) || _kucult(ders.ad).contains(aranan);
  }

  void _aramaDegisti(String deger) {
    setState(() {
      _arama = deger;
      _aramadaKapatilanlar.clear();
    });
  }

  void _grubuAcKapat(String grup) {
    setState(() {
      final hedef = _arama.trim().isEmpty ? _acikGruplar : _aramadaKapatilanlar;
      if (!hedef.add(grup)) hedef.remove(grup);
    });
  }

  void _dersSecimiDegisti(String kod, bool secildi) {
    setState(() {
      if (secildi) {
        _secili.add(kod);
      } else {
        _secili.remove(kod);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final aramaVar = _arama.trim().isNotEmpty;

    final bolumler = <Widget>[];
    for (final girdi in _gruplar.entries) {
      final dersler = aramaVar ? girdi.value.where(_eslesiyorMu).toList() : girdi.value;
      if (dersler.isEmpty) continue;

      final acik = aramaVar ? !_aramadaKapatilanlar.contains(girdi.key) : _acikGruplar.contains(girdi.key);
      final seciliSayisi = girdi.value.where((d) => _secili.contains(d.kod)).length;

      bolumler.add(_GrupBolumu(
        baslik: 'Bilgisayar Müh. ${girdi.key}',
        dersler: dersler,
        acik: acik,
        seciliSayisi: seciliSayisi,
        seciliMi: _secili.contains,
        onBaslikTiklandi: () => _grubuAcKapat(girdi.key),
        onDersDegisti: _dersSecimiDegisti,
      ));
    }

    return FractionallySizedBox(
      heightFactor: 0.92,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Ders Seç',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Renkler.yazi),
                  ),
                ),
                IconButton(tooltip: 'Kapat', icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: TextField(
              controller: _aramaController,
              onChanged: _aramaDegisti,
              textInputAction: TextInputAction.search,
              decoration: formAlaniStili(
                'Ders kodu veya adı ara',
                Icons.search,
                sonEk: aramaVar
                    ? IconButton(
                        tooltip: 'Aramayı temizle',
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _aramaController.clear();
                          _aramaDegisti('');
                        },
                      )
                    : null,
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: bolumler.isEmpty
                ? const Center(
                    child: Text('Aramanızla eşleşen ders yok.', style: TextStyle(color: Renkler.yaziSoluk)),
                  )
                : ListView(padding: EdgeInsets.zero, children: bolumler),
          ),
          const Divider(),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${_secili.length} ders seçili',
                      style: const TextStyle(fontWeight: FontWeight.w600, color: Renkler.yazi),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, _secili),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12)),
                    child: const Text('Kaydet', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }
}

class _GrupBolumu extends StatelessWidget {
  const _GrupBolumu({
    required this.baslik,
    required this.dersler,
    required this.acik,
    required this.seciliSayisi,
    required this.seciliMi,
    required this.onBaslikTiklandi,
    required this.onDersDegisti,
  });

  final String baslik;
  final List<DersSecenegi> dersler;
  final bool acik;
  final int seciliSayisi;
  final bool Function(String) seciliMi;
  final VoidCallback onBaslikTiklandi;
  final void Function(String kod, bool secildi) onDersDegisti;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onBaslikTiklandi,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    baslik,
                    style: const TextStyle(fontWeight: FontWeight.w600, color: Renkler.yazi),
                  ),
                ),
                if (seciliSayisi > 0)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(color: Renkler.vurgu, borderRadius: BorderRadius.circular(10)),
                    child: Text(
                      '$seciliSayisi',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                AnimatedRotation(
                  turns: acik ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.expand_more, color: Renkler.yaziSoluk),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.topCenter,
          child: acik
              ? Column(
                  children: [
                    for (final ders in dersler)
                      CheckboxListTile(
                        value: seciliMi(ders.kod),
                        onChanged: (deger) => onDersDegisti(ders.kod, deger ?? false),
                        controlAffinity: ListTileControlAffinity.leading,
                        dense: true,
                        activeColor: Renkler.vurgu,
                        title: Text(ders.kod, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: ders.ad == ders.kod ? null : Text(ders.ad),
                      ),
                  ],
                )
              : const SizedBox(width: double.infinity),
        ),
        const Divider(),
      ],
    );
  }
}
