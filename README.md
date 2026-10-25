# AÜ Hub — Kampüs Portalı

BLM4587 IOS İle Mobil Uygulama Geliştirme I Dönem Projesi: Ankara Üniversitesi Kampüs Portalı (AÜ Hub)

---

## Proje Yapısı

```
BLM4587-Proje/
├── api/       → ASP.NET Core Web API (.NET 10)
└── mobile/    → Flutter Mobil Uygulaması (Dart)
```

---

## Web API Kurulumu

### Gereksinimler
- [.NET 10 SDK](https://dotnet.microsoft.com/download)
- [PostgreSQL 15+](https://www.postgresql.org/download/)
- [dotnet-ef CLI aracı](https://learn.microsoft.com/en-us/ef/core/cli/dotnet)

### 1. dotnet-ef Aracını Yükle (Yalnızca İlk Kurulumda)
```bash
dotnet tool install --global dotnet-ef
```

### 2. Bağlantı Dizesini Ayarla

`api/appsettings.json` dosyası `.gitignore`'da olduğu için depoda bulunmaz. `api/` klasörünün içinde bu dosyayı kendin oluşturman gerekir:

```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*",
  "ConnectionStrings": {
    "DefaultConnection": "Host=localhost;Port=5432;Database=auhub_db;Username=postgres;Password=SENIN_SIFREN"
  }
}
```

> ⚠️ `SENIN_SIFREN` kısmını kendi PostgreSQL şifrenle değiştir. Bu dosyayı **asla** GitHub'a gönderme.

### 3. Veritabanını Oluştur

Terminalde `api/` klasörünün içindeyken şu komutları çalıştır:

```bash
# Migration'ı veritabanına uygula (tablolar otomatik oluşur)
dotnet ef database update
```

> Tablolar oluşturuldu mu? DBeaver veya pgAdmin'den `auhub_db` veritabanına bağlanıp
> `Derslikler`, `Etkinlikler`, `KayipEsyalar`, `Kullanicilar`, `KutuphaneMasalari` tablolarını kontrol edebilirsin.

### 4. API'yi Başlat

```bash
cd api
dotnet run
```

API varsayılan olarak `https://localhost:5001` adresinde çalışır.  
Swagger arayüzü için: `https://localhost:5001/openapi`

---

## Mobil Uygulama Kurulumu

Ayrıntılar için → [`mobile/README.md`](mobile/README.md)

```bash
cd mobile
flutter pub get
flutter run
```

### API Adresini Ayarla

Mobil uygulama ilerleyen haftalarda `mobile/lib/core/constants/api_constants.dart` dosyasındaki `baseUrl` değişkeni üzerinden API adresine bağlanacak. Şimdilik:

- **Emülatör/Simulator** kullanıyorsan: `http://10.0.2.2:5000` (Android) veya `http://localhost:5000` (iOS)
- **Gerçek cihaz** kullanıyorsan: bilgisayarının yerel IP adresi, örn. `http://192.168.1.X:5000`

---

## Kullanılan Teknolojiler

| Katman | Teknoloji |
|---|---|
| Mobil Uygulama | Flutter 3.47.5 (Dart) |
| Web API | ASP.NET Core (.NET 10) |
| Veritabanı | PostgreSQL |
| ORM | Entity Framework Core 10 |
| API Dokümantasyonu | OpenAPI / Swagger |

## Veritabanı Tabloları

| Tablo | Açıklama |
|---|---|
| `Kullanicilar` | Kullanıcı hesapları (Ad, Email, SifreHash, Rol) |
| `Derslikler` | Rezerve edilebilir derslikler |
| `KutuphaneMasalari` | Kütüphane masa rezervasyonları |
| `Etkinlikler` | Kampüs etkinlik duyuruları |
| `KayipEsyalar` | Kayıp/bulunan eşya bildirimleri |
