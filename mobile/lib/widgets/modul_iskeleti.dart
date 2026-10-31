import 'package:flutter/material.dart';

// Henüz içeriği yazılmamış modül ekranlarının ortak görünümü:
// AppBar'da başlık, ortada ikon, kısa açıklama ve "Yakında" alanı.
class ModulIskeleti extends StatelessWidget {
  const ModulIskeleti({
    super.key,
    required this.baslik,
    required this.ikon,
    required this.aciklama,
  });

  final String baslik;
  final IconData ikon;
  final String aciklama;

  @override
  Widget build(BuildContext context) {
    final renkler = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(baslik)),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(ikon, size: 72, color: renkler.primary),
              const SizedBox(height: 16),
              Text(
                baslik,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                aciklama,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: renkler.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.schedule, color: renkler.onSecondaryContainer),
                    const SizedBox(width: 8),
                    Text(
                      'Yakında',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: renkler.onSecondaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
