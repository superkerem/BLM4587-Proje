import 'package:flutter/material.dart';

InputDecoration formAlaniStili(String etiket, IconData ikon, {Widget? sonEk, String? ipucu}) {
  return InputDecoration(
    labelText: etiket,
    helperText: ipucu,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: yukleniyor
          ? const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
            )
          : Text(metin, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
        borderRadius: BorderRadius.circular(12),
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
