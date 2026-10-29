import 'package:flutter/material.dart';

import '../../core/constants/api_constants.dart';
import '../../models/kullanici.dart';
import '../../services/api_istemcisi.dart';
import '../../services/oturum_servisi.dart';
import '../erisim_engellendi_ekrani.dart';

class KullanicilarEkrani extends StatefulWidget {
  const KullanicilarEkrani({super.key});

  @override
  State<KullanicilarEkrani> createState() => _KullanicilarEkraniState();
}

class _KullanicilarEkraniState extends State<KullanicilarEkrani> {
  late Future<List<Kullanici>> _kullanicilar;

  @override
  void initState() {
    super.initState();
    _kullanicilar = _getir();
  }

  Future<List<Kullanici>> _getir() async {
    final liste = await OturumServisi.ornek.api.get(ApiSabitleri.yonetimKullanicilar) as List<dynamic>;
    return liste.map((e) => Kullanici.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> _yenile() async {
    final yeni = _getir();
    setState(() => _kullanicilar = yeni);
    await yeni.catchError((_) => <Kullanici>[]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Kullanici>>(
      future: _kullanicilar,
      builder: (context, durum) {
        final hata = durum.error;
        // Menü gizlense bile asıl kontrol API'de: rol yetmezse 403 döner.
        if (hata is ApiHatasi && hata.erisimEngellendi) {
          return const ErisimEngellendiEkrani();
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Yönetim · Kullanıcılar')),
          body: RefreshIndicator(
            onRefresh: _yenile,
            child: _icerik(durum),
          ),
        );
      },
    );
  }

  Widget _icerik(AsyncSnapshot<List<Kullanici>> durum) {
    if (durum.connectionState != ConnectionState.done) {
      return const Center(child: CircularProgressIndicator());
    }

    if (durum.hasError) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 80),
          const Icon(Icons.cloud_off, size: 56, color: Colors.grey),
          const SizedBox(height: 12),
          Text(durum.error.toString(), textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Center(child: FilledButton(onPressed: _yenile, child: const Text('Tekrar Dene'))),
        ],
      );
    }

    final kullanicilar = durum.data!;
    if (kullanicilar.isEmpty) {
      return ListView(children: const [SizedBox(height: 120), Center(child: Text('Kayıtlı kullanıcı yok.'))]);
    }

    return ListView.separated(
      itemCount: kullanicilar.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final k = kullanicilar[i];
        final tarih = k.kayitTarihi;
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: k.yoneticiMi ? Colors.orange.shade100 : Colors.blue.shade50,
            child: Icon(k.yoneticiMi ? Icons.admin_panel_settings : Icons.person),
          ),
          title: Text(k.adSoyad),
          subtitle: Text([
            k.email ?? '',
            if (k.ogrenciNo != null) 'No: ${k.ogrenciNo}',
            'Kayıt: ${tarih.day.toString().padLeft(2, '0')}.${tarih.month.toString().padLeft(2, '0')}.${tarih.year}',
          ].join('\n')),
          isThreeLine: true,
          trailing: Wrap(
            spacing: 4,
            children: k.roller.map((r) => Chip(label: Text(r), visualDensity: VisualDensity.compact)).toList(),
          ),
        );
      },
    );
  }
}
