import 'package:flutter/material.dart';

import '../../core/dogrulayicilar.dart';
import '../../core/tema.dart';
import '../../core/turkiye_saati.dart';
import '../../models/ders_programi.dart';
import '../../models/sinav.dart';
import '../../services/api_istemcisi.dart';
import '../../services/kampus_servisi.dart';
import '../../services/sinav_servisi.dart';
import '../../widgets/form_ogeleri.dart';
import '../../widgets/panel_ogeleri.dart';

class SinavFormEkrani extends StatefulWidget {
  const SinavFormEkrani({super.key, this.sinavId});

  final int? sinavId;

  @override
  State<SinavFormEkrani> createState() => _SinavFormEkraniState();
}

class _SinavFormEkraniState extends State<SinavFormEkrani> {
  final _formKey = GlobalKey<FormState>();
  final _dersController = TextEditingController();
  final _tarihController = TextEditingController();
  final _baslangicController = TextEditingController();
  final _bitisController = TextEditingController();

  late Future<DersProgrami> _hazirlik = _hazirla();
  DersProgrami? _program;

  String? _dersKodu;
  SinavTuru? _tur = SinavTuru.vize;
  DateTime? _tarih;
  int? _baslangic;
  int? _bitis;
  Set<int> _derslikler = {};

  bool _yukleniyor = false;
  String? _genelHata;
  Map<String, String> _sunucuHatalari = {};

  bool get _duzenlemeMi => widget.sinavId != null;

  @override
  void dispose() {
    for (final c in [_dersController, _tarihController, _baslangicController, _bitisController]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<DersProgrami> _hazirla() async {
    final program = await KampusServisi.dersProgrami();
    _program = program;
    final id = widget.sinavId;
    if (id != null) {
      final detay = await SinavServisi.getir(id);
      _dersKodu = detay.dersKodu;
      _tur = detay.tur;
      _tarih = detay.tarih;
      _baslangic = detay.baslangic;
      _bitis = detay.bitis;
      _derslikler = {...detay.derslikIdleri};
      _dersController.text = _dersEtiketi(program, detay.dersKodu);
      _tarihController.text = TurkceTarih.uzun(detay.tarih);
      _baslangicController.text = TurkiyeSaati.saatMetni(detay.baslangic);
      _bitisController.text = TurkiyeSaati.saatMetni(detay.bitis);
    }
    return program;
  }

  void _tekrarDene() {
    setState(() {
      _hazirlik = _hazirla();
    });
  }

  String _dersEtiketi(DersProgrami program, String kod) {
    final ad = program.dersAdi(kod);
    return ad == kod ? kod : '$kod · $ad';
  }

  Future<void> _dersSec() async {
    final program = _program;
    if (program == null) return;
    final secilen = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _DersSecici(secenekler: program.secenekler, seciliKod: _dersKodu),
    );
    if (secilen == null) return;
    setState(() {
      _dersKodu = secilen;
      _dersController.text = _dersEtiketi(program, secilen);
      _sunucuHatalari.remove('derskodu');
    });
  }

  Future<void> _tarihSec() async {
    final simdi = TurkiyeSaati.simdi();
    final bugun = DateTime(simdi.year, simdi.month, simdi.day);
    final baslangic = _tarih ?? bugun;
    final secilen = await showDatePicker(
      context: context,
      initialDate: baslangic,
      firstDate: DateTime(bugun.year - 1),
      lastDate: DateTime(bugun.year + 2, 12, 31),
      helpText: 'Sınav tarihi',
      cancelText: 'Vazgeç',
      confirmText: 'Seç',
    );
    if (secilen == null) return;
    setState(() {
      _tarih = secilen;
      _tarihController.text = TurkceTarih.uzun(secilen);
      _sunucuHatalari.remove('tarih');
    });
  }

  Future<void> _saatSec(bool baslangicMi) async {
    final mevcut = baslangicMi ? _baslangic : _bitis;
    final varsayilan = baslangicMi ? 9 * 60 : (_baslangic ?? 9 * 60) + 60;
    final dakika = mevcut ?? varsayilan;
    final secilen = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: (dakika ~/ 60) % 24, minute: dakika % 60),
      helpText: baslangicMi ? 'Başlangıç saati' : 'Bitiş saati',
      cancelText: 'Vazgeç',
      confirmText: 'Seç',
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (secilen == null) return;
    final deger = secilen.hour * 60 + secilen.minute;
    setState(() {
      if (baslangicMi) {
        _baslangic = deger;
        _baslangicController.text = TurkiyeSaati.saatMetni(deger);
        _sunucuHatalari.remove('baslangic');
      } else {
        _bitis = deger;
        _bitisController.text = TurkiyeSaati.saatMetni(deger);
      }
      _sunucuHatalari.remove('bitis');
    });
  }

  Future<void> _kaydet() async {
    _sunucuHatalari = {};
    setState(() => _genelHata = null);

    if (!_formKey.currentState!.validate()) return;

    final navigator = Navigator.of(context);
    final mesajci = ScaffoldMessenger.of(context);
    final govde = SinavServisi.govdeOlustur(
      dersKodu: _dersKodu,
      tur: _tur,
      tarih: _tarih,
      baslangic: _baslangic,
      bitis: _bitis,
      derslikIdleri: _derslikler,
    );

    setState(() => _yukleniyor = true);
    try {
      if (_duzenlemeMi) {
        await SinavServisi.guncelle(widget.sinavId!, govde);
      } else {
        await SinavServisi.ekle(govde);
      }
      mesajci.showSnackBar(const SnackBar(content: Text('Sınav kaydedildi.')));
      navigator.pop(true);
    } on ApiHatasi catch (hata) {
      if (!mounted) return;
      setState(() {
        _genelHata = hata.alanHatalari[''] ?? hata.mesaj;
        _sunucuHatalari = {...hata.alanHatalari};
      });
      _formKey.currentState!.validate();
    } finally {
      if (mounted) setState(() => _yukleniyor = false);
    }
  }

  String? Function(T) _dogrula<T>(String alan, String? Function(T) kural) {
    return (deger) => _sunucuHatalari[alan] ?? kural(deger);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_duzenlemeMi ? 'Sınavı Düzenle' : 'Sınav Ekle')),
      body: FutureBuilder<DersProgrami>(
        future: _hazirlik,
        builder: (context, durum) {
          if (durum.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (durum.hasError) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                BosDurum(
                  ikon: Icons.cloud_off,
                  baslik: 'Form hazırlanamadı',
                  aciklama: durum.error.toString(),
                  dugmeMetni: 'Tekrar Dene',
                  dugmeyeBasilinca: _tekrarDene,
                ),
              ],
            );
          }
          return _form(durum.data!);
        },
      ),
    );
  }

  Widget _form(DersProgrami program) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        PanelKart(
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_genelHata != null) ...[
                  HataKutusu(mesaj: _genelHata!),
                  const SizedBox(height: 16),
                ],
                TextFormField(
                  controller: _dersController,
                  readOnly: true,
                  onTap: _dersSec,
                  decoration: formAlaniStili('Ders', Icons.menu_book_outlined, sonEk: const Icon(Icons.search)),
                  validator: _dogrula<String?>('derskodu', (_) => Dogrulayicilar.sinavDersi(_dersKodu)),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<SinavTuru>(
                  initialValue: _tur,
                  isExpanded: true,
                  decoration: formAlaniStili('Sınav Türü', Icons.category_outlined),
                  items: [
                    for (final tur in SinavTuru.values) DropdownMenuItem(value: tur, child: Text(tur.etiket)),
                  ],
                  onChanged: (tur) => setState(() {
                    _tur = tur;
                    _sunucuHatalari.remove('tur');
                  }),
                  validator: _dogrula<SinavTuru?>('tur', Dogrulayicilar.sinavTuru),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _tarihController,
                  readOnly: true,
                  onTap: _tarihSec,
                  decoration: formAlaniStili('Tarih', Icons.event_outlined, sonEk: const Icon(Icons.arrow_drop_down)),
                  validator: _dogrula<String?>('tarih', (_) => Dogrulayicilar.sinavTarihi(_tarih)),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _baslangicController,
                        readOnly: true,
                        onTap: () => _saatSec(true),
                        decoration: formAlaniStili('Başlangıç', Icons.schedule),
                        validator: _dogrula<String?>(
                          'baslangic',
                          (_) => Dogrulayicilar.sinavBaslangici(_baslangic),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _bitisController,
                        readOnly: true,
                        onTap: () => _saatSec(false),
                        decoration: formAlaniStili('Bitiş', Icons.schedule),
                        validator: _dogrula<String?>(
                          'bitis',
                          (_) => Dogrulayicilar.sinavBitisi(_baslangic, _bitis),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                FormField<Set<int>>(
                  initialValue: _derslikler,
                  validator: _dogrula<Set<int>?>('derslikidleri', (_) => Dogrulayicilar.sinavDerslikleri(_derslikler)),
                  builder: (alan) => _DerslikSecimi(
                    derslikler: program.derslikler,
                    secili: _derslikler,
                    hata: alan.errorText,
                    onDegisti: (yeni) {
                      setState(() {
                        _derslikler = yeni;
                        _sunucuHatalari.remove('derslikidleri');
                      });
                      alan.didChange(yeni);
                    },
                  ),
                ),
                const SizedBox(height: 24),
                AnaButon(
                  metin: _duzenlemeMi ? 'Kaydet' : 'Sınavı Ekle',
                  yukleniyor: _yukleniyor,
                  onPressed: _kaydet,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DersSecici extends StatefulWidget {
  const _DersSecici({required this.secenekler, this.seciliKod});

  final List<DersSecenegi> secenekler;
  final String? seciliKod;

  @override
  State<_DersSecici> createState() => _DersSeciciState();
}

class _DersSeciciState extends State<_DersSecici> {
  String _arama = '';

  @override
  Widget build(BuildContext context) {
    final arama = _arama.trim().toLowerCase();
    final liste = arama.isEmpty
        ? widget.secenekler
        : widget.secenekler
            .where((s) => s.kod.toLowerCase().contains(arama) || s.ad.toLowerCase().contains(arama))
            .toList();

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                autofocus: true,
                decoration: formAlaniStili('Ders ara', Icons.search, ipucu: 'Kod veya ders adı'),
                onChanged: (deger) => setState(() => _arama = deger),
              ),
            ),
            Expanded(
              child: liste.isEmpty
                  ? const Center(
                      child: Text('Eşleşen ders yok.', style: TextStyle(color: Renkler.yaziSoluk)),
                    )
                  : ListView.separated(
                      itemCount: liste.length,
                      separatorBuilder: (_, _) => const Divider(),
                      itemBuilder: (context, i) {
                        final secenek = liste[i];
                        final secili = secenek.kod == widget.seciliKod;
                        return ListTile(
                          title: Text(
                            secenek.ad == secenek.kod ? secenek.kod : '${secenek.kod} · ${secenek.ad}',
                            style: TextStyle(fontWeight: secili ? FontWeight.w600 : FontWeight.w400),
                          ),
                          trailing: secili ? const Icon(Icons.check, color: Renkler.vurgu) : null,
                          onTap: () => Navigator.pop(context, secenek.kod),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DerslikSecimi extends StatelessWidget {
  const _DerslikSecimi({
    required this.derslikler,
    required this.secili,
    required this.onDegisti,
    this.hata,
  });

  final List<Derslik> derslikler;
  final Set<int> secili;
  final ValueChanged<Set<int>> onDegisti;
  final String? hata;

  List<MapEntry<String, List<Derslik>>> _gruplar() {
    final kampus = <String, List<Derslik>>{};
    final disarida = <Derslik>[];
    for (final derslik in derslikler) {
      if (derslik.kampusteMi) {
        kampus.putIfAbsent(derslik.mekanAdi ?? 'Diğer', () => []).add(derslik);
      } else {
        disarida.add(derslik);
      }
    }
    final siralar = kampus.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    for (final grup in siralar) {
      grup.value.sort((a, b) => a.ad.compareTo(b.ad));
    }
    if (disarida.isNotEmpty) {
      siralar.add(MapEntry('Kampüs dışı', disarida..sort((a, b) => a.ad.compareTo(b.ad))));
    }
    return siralar;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          secili.isEmpty ? 'Derslikler' : 'Derslikler (${secili.length} seçili)',
          style: const TextStyle(fontWeight: FontWeight.w600, color: Renkler.yazi),
        ),
        const SizedBox(height: 8),
        for (final grup in _gruplar()) ...[
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 6),
            child: Text(grup.key, style: const TextStyle(fontSize: 13, color: Renkler.yaziSoluk)),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final derslik in grup.value)
                FilterChip(
                  label: Text(derslik.ad),
                  selected: secili.contains(derslik.id),
                  selectedColor: Renkler.vurguAcik,
                  checkmarkColor: Renkler.vurgu,
                  onSelected: (secildi) {
                    final yeni = {...secili};
                    if (secildi) {
                      yeni.add(derslik.id);
                    } else {
                      yeni.remove(derslik.id);
                    }
                    onDegisti(yeni);
                  },
                ),
            ],
          ),
        ],
        if (hata != null) ...[
          const SizedBox(height: 8),
          Text(hata!, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.error)),
        ],
      ],
    );
  }
}
