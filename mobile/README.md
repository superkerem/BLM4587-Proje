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

Uygulama, backend API'sine bağlanmak için bir adres kullanır.  
**Önce `api/` klasöründe Web API'yi başlatman gerekir** (bkz. [ana README](../README.md)).

| Senaryo | API Adresi |
|---|---|
| Android Emülatör | `http://10.0.2.2:5000` |
| iOS Simulator | `http://localhost:5000` |
| Gerçek Cihaz | `http://<bilgisayarın-IP>:5000` |

---

## Ekranlar

| Ekran | Durum |
|---|---|
| Giriş Ekranı | ✅ Hazır (1. Hafta) |
| Kayıt Ekranı | 🔜 Planlandı |
| Ana Sayfa | 🔜 Planlandı |
| Derslik Rezervasyonu | 🔜 Planlandı |
| Etkinlikler | 🔜 Planlandı |
| Yönetim Paneli | 🔜 Planlandı |

---

## Proje Hakkında

API ve kurulum bilgileri için → [Ana README](../README.md)
