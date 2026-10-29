import 'package:flutter/material.dart';

import '../core/dogrulayicilar.dart';
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

    // 1. aşama: cihazdaki kontrol. Geçersizse API'ye hiç istek atılmaz.
    if (!_formKey.currentState!.validate()) return;

    setState(() => _yukleniyor = true);
    try {
      // 2. aşama: API aynı kuralları tekrar kontrol eder ve şifreyi doğrular.
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
      // API'den gelen alan hataları ilgili alanın altında gösterilir.
      _formKey.currentState!.validate();
    } finally {
      if (mounted) setState(() => _yukleniyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final renk = Colors.blue.shade700;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset('assets/images/au_logo.png', height: 100),
                    Text(
                      'AÜ Hub',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: renk),
                    ),
                    const Text(
                      'Kampüs Portalına Hoş Geldiniz',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 40),
                    if (_genelHata != null) ...[
                      HataKutusu(mesaj: _genelHata!),
                      const SizedBox(height: 16),
                    ],
                    TextFormField(
                      controller: _kullaniciAdiController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                      decoration: formAlaniStili('Öğrenci No veya E-posta', Icons.person),
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
                        Icons.lock,
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
                    TextButton(
                      onPressed: _yukleniyor ? null : () => Navigator.pushNamed(context, '/kayit'),
                      child: const Text('Hesabın yok mu? Kayıt Ol'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
