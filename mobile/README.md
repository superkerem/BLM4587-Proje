# AÜ Hub — Mobil Uygulama

AÜ Hub projesinin Flutter ile geliştirilmiş mobil uygulaması. Kampüs hizmetlerine (derslik/kütüphane rezervasyonu, etkinlikler, kayıp eşya) erişim sağlar.

---

## Gereksinimler

- Flutter **3.47.5** veya üzeri
- Dart SDK (Flutter ile birlikte gelir)
- Android Emülatör veya gerçek Android/iOS cihazı

Flutter versiyonunu kontrol etmek için:
```bash
flutter --version
```

---

## Kurulum ve Çalıştırma

```bash
# 1. Bağımlılıkları yükle
flutter pub get

# 2. Uygulamayı başlat
flutter run
```

Belirli bir cihazı hedeflemek için:
```bash
# Bağlı cihazları listele
flutter devices

# Belirli cihazda çalıştır
flutter run -d <device_id>
```

---

## API Adresini Ayarla

Uygulama, backend API'sine bağlanmak için `lib/core/constants/api_constants.dart` içindeki `ApiSabitleri.baseUrl` adresini kullanır.
**Önce `api/` klasöründe Web API'yi başlatman gerekir** (bkz. [ana README](../README.md)).

| Senaryo | API Adresi | Nasıl |
|---|---|---|
| Android Emülatör | `http://10.0.2.2:5135` | Varsayılan, bir şey yapma |
| iOS Simulator | `http://localhost:5135` | Varsayılan, bir şey yapma |
| Gerçek Cihaz | `http://<bilgisayarın-IP>:5135` | `flutter run --dart-define=API_URL=http://192.168.1.X:5135` |

---

## Klasör Yapısı

```
lib/
├── core/
│   ├── constants/api_constants.dart  → API adresi ve uç noktalar
│   ├── dogrulayicilar.dart           → Form doğrulama kuralları (API'deki Data Annotations karşılığı)
│   ├── moduller.dart                 → Kampüs modüllerinin başlık, ikon, rota ve açıklamaları
│   ├── roller.dart                   → Rol adları (Yonetici, Kullanici)
│   ├── tema.dart                     → Renkler ve Türkçe tarih biçimi
│   └── turkiye_saati.dart            → Türkiye saati (UTC+3) ve saat biçimleri
├── models/                           → kullanici.dart, duyuru.dart, kayip_esya.dart, mekan.dart, ders_programi.dart
├── services/
│   ├── api_istemcisi.dart            → HTTP istekleri, JWT başlığı, hata çözümleme
│   ├── oturum_servisi.dart           → Giriş/kayıt/çıkış, token saklama
│   ├── duyuru_servisi.dart           → Duyuruları API'den çeker
│   ├── kayip_esya_servisi.dart       → Kayıp eşya ilanları
│   └── kampus_servisi.dart           → Binalar, ders programı, seçilen dersler ve sınavlar
├── screens/
│   ├── giris_ekrani.dart
│   ├── kayit_ekrani.dart
│   ├── ana_sayfa.dart                → Karşılama, modül kartları ve duyurular
│   ├── kampus/                       → Modül ekranları (harita, derslik bulucu, kayıp eşya, diğerleri iskelet)
│   ├── erisim_engellendi_ekrani.dart
│   └── yonetim/kullanicilar_ekrani.dart  → Yalnızca Yönetici
├── widgets/                          → form_ogeleri, panel_ogeleri, yan_menu, modul_iskeleti
└── main.dart                         → Rotalar ve rol kontrolü
```


## Kampüs Haritası

Harita `flutter_map` paketiyle OpenStreetMap altlığı üzerinde çizilir; binalar API'den GeoJSON olarak gelir.
`flutter_map` kamerayı eğemediği için binalar duvar, çatı ve gölge katmanlarıyla 3B görünümde çizilir.

---

## Proje Hakkında

API ve kurulum bilgileri için → [Ana README](../README.md)
