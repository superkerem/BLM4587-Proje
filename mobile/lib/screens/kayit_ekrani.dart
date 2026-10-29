import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/dogrulayicilar.dart';
import '../services/api_istemcisi.dart';
import '../services/oturum_servisi.dart';
import '../widgets/form_ogeleri.dart';

class KayitEkrani extends StatefulWidget {
  const KayitEkrani({super.key});

  @override
  State<KayitEkrani> createState() => _KayitEkraniState();
}

class _KayitEkraniState extends State<KayitEkrani> {
  final _formKey = GlobalKey<FormState>();
  final _adController = TextEditingController();
  final _soyadController = TextEditingController();
  final _ogrenciNoController = TextEditingController();
  final _emailController = TextEditingController();
  final _sifreController = TextEditingController();
  final _sifreTekrarController = TextEditingController();

  bool _yukleniyor = false;
  bool _sifreGizli = true;
  String? _genelHata;
  Map<String, String> _sunucuHatalari = {};

  @override
  void dispose() {
    for (final c in [
      _adController,
      _soyadController,
      _ogrenciNoController,
      _emailController,
      _sifreController,
      _sifreTekrarController,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _kayitOl() async {
    _sunucuHatalari = {};
    setState(() => _genelHata = null);

    if (!_formKey.currentState!.validate()) return;

    final mesajci = ScaffoldMessenger.of(context);
    setState(() => _yukleniyor = true);
    try {
      // Başarılı olursa API token döner ve kullanıcı doğrudan giriş yapmış olur.
      await OturumServisi.ornek.kayitOl(
        ad: _adController.text,
        soyad: _soyadController.text,
        ogrenciNo: _ogrenciNoController.text,
        email: _emailController.text,
        sifre: _sifreController.text,
        sifreTekrar: _sifreTekrarController.text,
      );
      mesajci.showSnackBar(
        SnackBar(content: Text('Hoş geldin ${OturumServisi.ornek.kullanici?.ad}! Kaydın başarıyla oluşturuldu.')),
      );
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

  // İstemci kuralı geçse bile API'den gelen hata (ör. "e-posta zaten kayıtlı") öncelikli gösterilir.
  String? Function(String?) _dogrula(String alan, String? Function(String?) kural) {
    return (deger) => _sunucuHatalari[alan] ?? kural(deger);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kayıt Ol')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
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
                      controller: _adController,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      decoration: formAlaniStili('Ad', Icons.badge_outlined),
                      validator: _dogrula('ad', (d) => Dogrulayicilar.adSoyad(d, 'Ad')),
                      onChanged: (_) => _sunucuHatalari.remove('ad'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _soyadController,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      decoration: formAlaniStili('Soyad', Icons.badge_outlined),
                      validator: _dogrula('soyad', (d) => Dogrulayicilar.adSoyad(d, 'Soyad')),
                      onChanged: (_) => _sunucuHatalari.remove('soyad'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _ogrenciNoController,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(11),
                      ],
                      decoration: formAlaniStili(
                        'Öğrenci No',
                        Icons.numbers,
                        ipucu: 'Personel boş bırakabilir',
                      ),
                      validator: _dogrula('ogrencino', Dogrulayicilar.ogrenciNo),
                      onChanged: (_) => _sunucuHatalari.remove('ogrencino'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      decoration: formAlaniStili('E-posta', Icons.email_outlined),
                      validator: _dogrula('email', Dogrulayicilar.email),
                      onChanged: (_) => _sunucuHatalari.remove('email'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _sifreController,
                      obscureText: _sifreGizli,
                      textInputAction: TextInputAction.next,
                      decoration: formAlaniStili(
                        'Şifre',
                        Icons.lock_outline,
                        ipucu: 'En az 8 karakter, bir küçük harf ve bir rakam',
                        sonEk: IconButton(
                          icon: Icon(_sifreGizli ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => _sifreGizli = !_sifreGizli),
                        ),
                      ),
                      validator: _dogrula('sifre', Dogrulayicilar.sifre),
                      onChanged: (_) => _sunucuHatalari.remove('sifre'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _sifreTekrarController,
                      obscureText: _sifreGizli,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _kayitOl(),
                      decoration: formAlaniStili('Şifre (Tekrar)', Icons.lock_outline),
                      validator: _dogrula(
                        'sifretekrar',
                        (d) => Dogrulayicilar.sifreTekrar(d, _sifreController.text),
                      ),
                      onChanged: (_) => _sunucuHatalari.remove('sifretekrar'),
                    ),
                    const SizedBox(height: 24),
                    AnaButon(metin: 'Kayıt Ol', yukleniyor: _yukleniyor, onPressed: _kayitOl),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _yukleniyor ? null : () => Navigator.pop(context),
                      child: const Text('Zaten hesabın var mı? Giriş Yap'),
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
