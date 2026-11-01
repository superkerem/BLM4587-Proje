import 'package:flutter/material.dart';

import '../core/tema.dart';

InputDecoration formAlaniStili(String etiket, IconData ikon, {Widget? sonEk, String? ipucu}) {
  return InputDecoration(
    labelText: etiket,
    helperText: ipucu,
    prefixIcon: Icon(ikon),
    suffixIcon: sonEk,
  );
}

class AnaButon extends StatelessWidget {
  const AnaButon({super.key, required this.metin, required this.onPressed, this.yukleniyor = false});

  final String metin;
  final VoidCallback onPressed;
  final bool yukleniyor;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: yukleniyor ? null : onPressed,
      child: yukleniyor
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
            )
          : Text(metin, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
    );
  }
}

class HataKutusu extends StatelessWidget {
  const HataKutusu({super.key, required this.mesaj});

  final String mesaj;

  @override
  Widget build(BuildContext context) {
    final renk = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: renk.errorContainer,
        borderRadius: BorderRadius.circular(Tema.kose),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: renk.onErrorContainer),
          const SizedBox(width: 8),
          Expanded(child: Text(mesaj, style: TextStyle(color: renk.onErrorContainer))),
        ],
      ),
    );
  }
}

class GirisDuzeni extends StatelessWidget {
  const GirisDuzeni({
    super.key,
    required this.baslik,
    required this.altBaslik,
    required this.child,
    this.geriDugmesi = false,
  });

  final String baslik;
  final String altBaslik;
  final Widget child;
  final bool geriDugmesi;

  @override
  Widget build(BuildContext context) {
    final yukseklik = MediaQuery.sizeOf(context).height;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: yukseklik * 0.42,
            child: const ColoredBox(color: Renkler.vurgu),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (geriDugmesi)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            tooltip: 'Geri',
                            color: Colors.white,
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => Navigator.maybePop(context),
                          ),
                        ),
                      const _Marka(),
                      const SizedBox(height: 24),
                      Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: Renkler.yuzey,
                          borderRadius: BorderRadius.circular(Tema.kose),
                          boxShadow: const [
                            BoxShadow(color: Color(0x140F2346), blurRadius: 24, offset: Offset(0, 8)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(height: 4, color: Renkler.vurgu),
                            Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    baslik,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Renkler.yazi,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(altBaslik, style: const TextStyle(color: Renkler.yaziSoluk)),
                                  const SizedBox(height: 20),
                                  child,
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '© 2026 AÜ Hub',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Renkler.yaziSoluk, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Marka extends StatelessWidget {
  const _Marka();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(Tema.kose)),
          child: Image.asset('assets/images/au_logo.png', height: 44),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ankara Üniversitesi', style: TextStyle(color: Colors.white70, fontSize: 13)),
            Text(
              'Kampüs Portalı',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }
}
