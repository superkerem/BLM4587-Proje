import 'package:flutter/material.dart';

import '../core/dogrulayicilar.dart';
import '../core/tema.dart';
import '../services/api_istemcisi.dart';
import '../services/oturum_servisi.dart';
import '../widgets/form_ogeleri.dart';

class GirisEkrani extends StatefulWidget {
  const GirisEkrani({super.key});

  @override
  State<GirisEkrani> createState() => _GirisEkraniState();
}

class _GirisEkraniState extends State<GirisEkrani> {
  final _formKey = GlobalKey<FormState>();
  final _kullaniciAdiController = TextEditingController();
  final _sifreController = TextEditingController();

  bool _beniHatirla = false;
  bool _yukleniyor = false;
  bool _sifreGizli = true;
  String? _genelHata;
  Map<String, String> _sunucuHatalari = {};

  @override
  void dispose() {
    _kullaniciAdiController.dispose();
    _sifreController.dispose();
    super.dispose();
  }

  Future<void> _girisYap() async {
    _sunucuHatalari = {};
    setState(() => _genelHata = null);

    if (!_formKey.currentState!.validate()) return;

    setState(() => _yukleniyor = true);
    try {
      await OturumServisi.ornek.girisYap(
        _kullaniciAdiController.text,
        _sifreController.text,
        beniHatirla: _beniHatirla,
      );
    } on ApiHatasi catch (hata) {
      if (!mounted) return;
      setState(() {
        _genelHata = hata.mesaj;
        _sunucuHatalari = {...hata.alanHatalari};
      });
      _formKey.currentState!.validate();
    } finally {
      if (mounted) setState(() => _yukleniyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GirisDuzeni(
      baslik: 'Giriş Yap',
      altBaslik: 'Öğrenci numaranız veya e-posta adresinizle giriş yapın.',
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
              controller: _kullaniciAdiController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autocorrect: false,
              decoration: formAlaniStili('Öğrenci No veya E-posta', Icons.person_outline),
              validator: (deger) =>
                  _sunucuHatalari['kullaniciadiveyaemail'] ?? Dogrulayicilar.kullaniciAdiVeyaEmail(deger),
              onChanged: (_) => _sunucuHatalari.remove('kullaniciadiveyaemail'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _sifreController,
              obscureText: _sifreGizli,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _girisYap(),
              decoration: formAlaniStili(
                'Şifre',
                Icons.lock_outline,
                sonEk: IconButton(
                  icon: Icon(_sifreGizli ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _sifreGizli = !_sifreGizli),
                ),
              ),
              validator: (deger) => _sunucuHatalari['sifre'] ?? Dogrulayicilar.zorunlu(deger, 'Şifre'),
              onChanged: (_) => _sunucuHatalari.remove('sifre'),
            ),
            CheckboxListTile(
              value: _beniHatirla,
              onChanged: (deger) => setState(() => _beniHatirla = deger ?? false),
              title: const Text('Beni Hatırla'),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 8),
            AnaButon(metin: 'Giriş Yap', yukleniyor: _yukleniyor, onPressed: _girisYap),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Hesabınız yok mu?', style: TextStyle(color: Renkler.yaziSoluk)),
                TextButton(
                  onPressed: _yukleniyor ? null : () => Navigator.pushNamed(context, '/kayit'),
                  child: const Text('Kayıt Olun', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
