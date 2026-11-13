import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/dogrulayicilar.dart';
import '../../models/duyuru.dart';
import '../../services/api_istemcisi.dart';
import '../../services/duyuru_servisi.dart';
import '../../widgets/form_ogeleri.dart';
import '../../widgets/panel_ogeleri.dart';

// Duyuru ekleme ve düzenleme için ortak form; duyuru verilirse düzenleme modunda açılır.
class DuyuruFormEkrani extends StatefulWidget {
  const DuyuruFormEkrani({super.key, this.duyuru});

  final Duyuru? duyuru;

  @override
  State<DuyuruFormEkrani> createState() => _DuyuruFormEkraniState();
}

class _DuyuruFormEkraniState extends State<DuyuruFormEkrani> {
  final _formKey = GlobalKey<FormState>();
  late final _baslikController = TextEditingController(text: widget.duyuru?.baslik);
  late final _icerikController = TextEditingController(text: widget.duyuru?.icerik);

  late bool _onemli = widget.duyuru?.onemliMi ?? false;

  bool _yukleniyor = false;
  String? _genelHata;
  Map<String, String> _sunucuHatalari = {};

  bool get _duzenlemeMi => widget.duyuru != null;

  @override
  void dispose() {
    _baslikController.dispose();
    _icerikController.dispose();
    super.dispose();
  }

  Future<void> _kaydet() async {
    _sunucuHatalari = {};
    setState(() => _genelHata = null);

    if (!_formKey.currentState!.validate()) return;

    final navigator = Navigator.of(context);
    final mesajci = ScaffoldMessenger.of(context);
    final govde = DuyuruServisi.govdeOlustur(
      baslik: _baslikController.text,
      icerik: _icerikController.text,
      onemliMi: _onemli,
    );

    setState(() => _yukleniyor = true);
    try {
      if (_duzenlemeMi) {
        await DuyuruServisi.guncelle(widget.duyuru!.id, govde);
      } else {
        await DuyuruServisi.ekle(govde);
      }
      mesajci.showSnackBar(const SnackBar(content: Text('Duyuru kaydedildi.')));
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

  // Önce sunucudan gelen alan hatası, yoksa istemci kuralı gösterilir.
  String? Function(String?) _dogrula(String alan, String? Function(String?) kural) {
    return (deger) => _sunucuHatalari[alan] ?? kural(deger);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_duzenlemeMi ? 'Duyuruyu Düzenle' : 'Duyuru Ekle')),
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
                    maxLengthEnforcement: MaxLengthEnforcement.none,
                    decoration: formAlaniStili('Başlık', Icons.title, ipucu: 'Örn. Final sınav takvimi açıklandı'),
                    validator: _dogrula('baslik', Dogrulayicilar.duyuruBaslik),
                    onChanged: (_) => _sunucuHatalari.remove('baslik'),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _icerikController,
                    textCapitalization: TextCapitalization.sentences,
                    keyboardType: TextInputType.multiline,
                    minLines: 5,
                    maxLines: 10,
                    maxLength: 2000,
                    maxLengthEnforcement: MaxLengthEnforcement.none,
                    decoration: formAlaniStili('İçerik', Icons.notes),
                    validator: _dogrula('icerik', Dogrulayicilar.duyuruIcerik),
                    onChanged: (_) => _sunucuHatalari.remove('icerik'),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Önemli'),
                    subtitle: const Text('Ana sayfada en üstte gösterilir.'),
                    value: _onemli,
                    onChanged: (deger) => setState(() => _onemli = deger),
                  ),
                  const SizedBox(height: 16),
                  AnaButon(
                    metin: _duzenlemeMi ? 'Kaydet' : 'Duyuruyu Ekle',
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
