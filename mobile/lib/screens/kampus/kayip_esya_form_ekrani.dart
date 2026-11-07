import 'package:flutter/material.dart';

import '../../models/kayip_esya.dart';
import '../../services/api_istemcisi.dart';
import '../../services/kayip_esya_servisi.dart';
import '../../widgets/form_ogeleri.dart';
import '../../widgets/panel_ogeleri.dart';

// İlan ekleme ve düzenleme için ortak form; esya verilirse düzenleme modunda açılır.
class KayipEsyaFormEkrani extends StatefulWidget {
  const KayipEsyaFormEkrani({super.key, this.esya});

  final KayipEsya? esya;

  @override
  State<KayipEsyaFormEkrani> createState() => _KayipEsyaFormEkraniState();
}

class _KayipEsyaFormEkraniState extends State<KayipEsyaFormEkrani> {
  final _formKey = GlobalKey<FormState>();
  late final _baslikController = TextEditingController(text: widget.esya?.baslik);
  late final _aciklamaController = TextEditingController(text: widget.esya?.aciklama);
  late final _yerController = TextEditingController(text: widget.esya?.bulunanYer);
  late final _tarihController = TextEditingController(text: KayipEsya.tarihYaz(_tarih));

  late DateTime _tarih = widget.esya?.bulunmaTarihi ?? DateTime.now();
  late bool _teslimEdildi = widget.esya?.teslimEdildiMi ?? false;

  bool _yukleniyor = false;
  String? _genelHata;
  Map<String, String> _sunucuHatalari = {};

  bool get _duzenlemeMi => widget.esya != null;

  @override
  void dispose() {
    for (final c in [_baslikController, _aciklamaController, _yerController, _tarihController]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _tarihSec() async {
    final simdi = DateTime.now();
    final secilen = await showDatePicker(
      context: context,
      initialDate: _tarih.isAfter(simdi) ? simdi : _tarih,
      firstDate: DateTime(simdi.year - 2),
      lastDate: simdi,
      helpText: 'Bulunma tarihi',
      cancelText: 'Vazgeç',
      confirmText: 'Seç',
    );
    if (secilen == null) return;
    setState(() {
      _tarih = secilen;
      _tarihController.text = KayipEsya.tarihYaz(secilen);
      _sunucuHatalari.remove('bulunmatarihi');
    });
  }

  Future<void> _kaydet() async {
    _sunucuHatalari = {};
    setState(() => _genelHata = null);

    if (!_formKey.currentState!.validate()) return;

    final navigator = Navigator.of(context);
    final mesajci = ScaffoldMessenger.of(context);
    final govde = KayipEsyaServisi.govdeOlustur(
      baslik: _baslikController.text,
      aciklama: _aciklamaController.text,
      bulunanYer: _yerController.text,
      bulunmaTarihi: _tarih,
      teslimEdildiMi: _teslimEdildi,
    );

    setState(() => _yukleniyor = true);
    try {
      final kaydedilen = _duzenlemeMi
          ? await KayipEsyaServisi.guncelle(widget.esya!.id, govde)
          : await KayipEsyaServisi.ekle(govde);
      mesajci.showSnackBar(SnackBar(content: Text(_duzenlemeMi ? 'İlan güncellendi.' : 'İlan eklendi.')));
      navigator.pop(kaydedilen);
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

  // Önce sunucudan gelen alan hatası, yoksa istemci kuralı gösterilir.
  String? Function(String?) _dogrula(String alan, String? Function(String) kural) {
    return (deger) => _sunucuHatalari[alan] ?? kural((deger ?? '').trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_duzenlemeMi ? 'İlanı Düzenle' : 'İlan Ekle')),
      body: ListView(
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
                    controller: _baslikController,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.sentences,
                    maxLength: 150,
                    decoration: formAlaniStili('Başlık', Icons.title, ipucu: 'Örn. Siyah sırt çantası'),
                    validator: _dogrula('baslik', (d) {
                      if (d.isEmpty) return 'Başlık zorunludur.';
                      if (d.length < 3) return 'Başlık 3-150 karakter arasında olmalıdır.';
                      return null;
                    }),
                    onChanged: (_) => _sunucuHatalari.remove('baslik'),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _aciklamaController,
                    textCapitalization: TextCapitalization.sentences,
                    minLines: 3,
                    maxLines: 6,
                    maxLength: 1000,
                    decoration: formAlaniStili('Açıklama', Icons.notes),
                    validator: _dogrula('aciklama', (d) => d.isEmpty ? 'Açıklama zorunludur.' : null),
                    onChanged: (_) => _sunucuHatalari.remove('aciklama'),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _yerController,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.sentences,
                    maxLength: 150,
                    decoration: formAlaniStili('Bulunduğu Yer', Icons.place_outlined),
                    validator: _dogrula('bulunanyer', (d) => d.isEmpty ? 'Bulunan yer zorunludur.' : null),
                    onChanged: (_) => _sunucuHatalari.remove('bulunanyer'),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _tarihController,
                    readOnly: true,
                    onTap: _tarihSec,
                    decoration: formAlaniStili(
                      'Bulunma Tarihi',
                      Icons.event_outlined,
                      sonEk: const Icon(Icons.arrow_drop_down),
                    ),
                    validator: _dogrula('bulunmatarihi', (_) => null),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Teslim edildi'),
                    subtitle: const Text('Eşya sahibine ulaştıysa işaretleyin.'),
                    value: _teslimEdildi,
                    onChanged: (deger) => setState(() => _teslimEdildi = deger),
                  ),
                  const SizedBox(height: 16),
                  AnaButon(
                    metin: _duzenlemeMi ? 'Kaydet' : 'İlanı Ekle',
                    yukleniyor: _yukleniyor,
                    onPressed: _kaydet,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
