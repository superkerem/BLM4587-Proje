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

### 2. Gizli Bilgileri User Secrets ile Ayarla (Yalnızca İlk Kurulumda)

Veritabanı şifresi, JWT gizli anahtarı ve yönetici şifresi **depoya konmaz**. `dotnet user-secrets` bu bilgileri bilgisayarındaki kullanıcı klasörüne kaydeder; `appsettings.json` dosyasını düzenlemene gerek yoktur.

`api/` klasörünün içindeyken:

```bash
# PostgreSQL bağlantı dizesi
dotnet user-secrets set "ConnectionStrings:DefaultConnection" "Host=localhost;Port=5432;Database=KampusPortaliMobilDb;Username=postgres;Password=SENIN_SIFREN"

# JWT imzalama anahtarı (en az 32 karakter, rastgele bir metin)
dotnet user-secrets set "Jwt:Anahtar" "$(openssl rand -base64 48)"

# İlk yönetici hesabı (uygulama açılışta bu hesap yoksa oluşturur ve Yonetici rolüne ekler)
dotnet user-secrets set "YoneticiHesabi:Email" "yonetici@ankara.edu.tr"
dotnet user-secrets set "YoneticiHesabi:Sifre" "GucluSifre123"
```

> Windows'ta `openssl` yoksa `Jwt:Anahtar` için en az 32 karakterlik herhangi bir rastgele metin yazabilirsin.
> Ayarları görmek için: `dotnet user-secrets list`

### 3. Veritabanını Oluştur

```bash
cd api
dotnet ef database update
```

> 2. haftada `Kullanicilar` tablosu ASP.NET Core Identity'ye taşındı ve `Roller`, `KullaniciRolleri`
> tabloları eklendi (`IdentityKurulumu` migration'ı). Model değiştirirsen yeni migration için:
> `dotnet ef migrations add MigrationAdi`
>
> `dotnet ef` komutları `Program.cs`'i çalıştırdığı için önce 2. adımdaki `Jwt:Anahtar` ayarlanmış olmalıdır.

### 4. API'yi Başlat

```bash
cd api
dotnet run
```

API varsayılan olarak `http://localhost:5135` adresinde çalışır (`Properties/launchSettings.json`).
OpenAPI belgesi: `http://localhost:5135/openapi/v1.json`. Uç noktaları denemek için `api/api.http` dosyası kullanılabilir.

### Kimlik Doğrulama ve Roller (2. Hafta)

- **ASP.NET Core Identity** kullanılır. `Kullanici` sınıfı `IdentityUser<int>`'ten türer; e-posta, kullanıcı adı ve şifre hash'i Identity'den gelir.
- Giriş **JWT** ile yapılır: giriş/kayıt başarılı olunca API bir token döner, mobil uygulama sonraki isteklerde `Authorization: Bearer <token>` başlığını gönderir.
- Roller: `Yonetici` ve `Kullanici`. Kayıt olan herkes `Kullanici` rolüne eklenir; yönetici hesabı User Secrets'tan okunarak oluşturulur.
- Şifre en az 8 karakter, en az bir rakam ve bir küçük harf içermelidir. Aynı e-posta ile ikinci kayıt yapılamaz. 5 hatalı girişte hesap 5 dakika kilitlenir.
- Gelen veriler **Data Annotations** ile doğrulanır; hatalı istekte API `400` ve `{ "mesaj": ..., "hatalar": { "alan": [...] } }` döner.

| Uç nokta | Yetki | Açıklama |
|---|---|---|
| `POST /api/hesap/kayit` | Herkes | Kayıt olur, token döner |
| `POST /api/hesap/giris` | Herkes | Öğrenci no veya e-posta + şifre ile giriş, token döner |
| `GET /api/hesap/ben` | Giriş yapmış | Token sahibinin bilgileri ve rolleri |
| `GET /api/yonetim/kullanicilar` | Yalnızca `Yonetici` | Tüm kullanıcılar ve rolleri |

Giriş yapmadan korumalı uç noktaya gelen istek `401`, rolü yetmeyen istek `403` alır.

---

## Mobil Uygulama Kurulumu

Ayrıntılar için → [`mobile/README.md`](mobile/README.md)

```bash
cd mobile
flutter pub get
flutter run
```

### API Adresini Ayarla

API adresi `mobile/lib/core/constants/api_constants.dart` dosyasındaki `ApiSabitleri.baseUrl` ile belirlenir:

- **Android Emülatör**: `http://10.0.2.2:5135` (varsayılan)
- **iOS Simulator**: `http://localhost:5135` (varsayılan)
- **Gerçek cihaz**: bilgisayarının yerel IP adresini çalıştırırken ver:
  `flutter run --dart-define=API_URL=http://192.168.1.X:5135`

---

## Kullanılan Teknolojiler

| Katman | Teknoloji |
|---|---|
| Mobil Uygulama | Flutter 3.47.5 (Dart) |
| Web API | ASP.NET Core (.NET 10) |
| Kimlik Doğrulama | ASP.NET Core Identity + JWT |
| Veritabanı | PostgreSQL |
| ORM | Entity Framework Core 10 |
| API Dokümantasyonu | OpenAPI / Swagger |

## Veritabanı Tabloları

| Tablo | İlişkiler |
|---|---|
| `Kullanicilar` (Identity) | KutuphaneMasalari (rezerve eden), KayipEsyalar (bildiren) |
| `Roller` (Identity) | KullaniciRolleri |
| `KullaniciRolleri` (Identity) | Kullanicilar, Roller (çoka-çok ara tablo) |
| `Akademisyenler` | Dersler |
| `Derslikler` | Dersler |
| `Dersler` | Derslikler, Akademisyenler |
| `KutuphaneMasalari` | Kullanicilar |
| `Etkinlikler` | - |
| `KayipEsyalar` | Kullanicilar |

Identity ayrıca `AspNetUserClaims`, `AspNetUserLogins`, `AspNetUserTokens` ve `AspNetRoleClaims` tablolarını oluşturur.
