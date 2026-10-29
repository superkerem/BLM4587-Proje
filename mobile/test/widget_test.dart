import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/screens/giris_ekrani.dart';
import 'package:mobile/screens/kayit_ekrani.dart';

void main() {
  testWidgets('Giriş formu boş gönderilince alan hataları görünür', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: GirisEkrani()));

    await tester.tap(find.text('Giriş Yap'));
    await tester.pump();

    expect(find.text('Öğrenci numarası veya e-posta zorunludur.'), findsOneWidget);
    expect(find.text('Şifre zorunludur.'), findsOneWidget);
  });

  testWidgets('Kayıt formunda şifreler eşleşmezse hata görünür', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: KayitEkrani()));

    final alanlar = find.byType(TextFormField);
    await tester.enterText(alanlar.at(0), 'Ali');
    await tester.enterText(alanlar.at(1), 'Yılmaz');
    await tester.enterText(alanlar.at(3), 'ali@ankara.edu.tr');
    await tester.enterText(alanlar.at(4), 'sifre1234');
    await tester.enterText(alanlar.at(5), 'sifre9999');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Kayıt Ol'));
    await tester.pump();

    expect(find.text('Şifreler eşleşmiyor.'), findsOneWidget);
  });
}
