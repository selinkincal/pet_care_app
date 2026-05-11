# 🐾 Pet Care Marketplace

Evcil hayvan sahipleri ile güvenilir bakım hizmetlerini buluşturan mobil uygulama.

## 👥 Geliştirici Ekibi

| İsim | Rol |
|------|-----|
| **Selin** | Proje Lideri & Frontend Developer |
| **Louai** | Backend & Firebase Entegrasyonu |
| **Naciye** | UI/UX Tasarım & Test |

*Bu proje 3 kişilik ekip tarafından geliştirilmektedir.*

## 📱 Proje Hakkında

Pet Care Marketplace, evcil hayvan sahiplerinin;
- 🐕 Bakım
- 🚶 Yürüyüş
- 🏥 Veteriner
- 🏠 Pansiyon

gibi hizmetlere kolayca ulaşmasını sağlayan bir mobil platformdur.

## 🛠️ Kullanılan Teknolojiler

| Teknoloji | Amaç |
|-----------|------|
| **Flutter** | Frontend mobile framework |
| **Dart** | Programlama dili |
| **SharedPreferences** | Yerel veri depolama |
| **Google Maps API** | Konum ve harita hizmetleri |
| **Image Picker** | Profil ve hayvan resmi yükleme |

## 📂 Proje Yapısı
lib/
├── screens/
│ ├── pet_owner_screens/ # Evcil hayvan sahibi ekranları
│ ├── service_provider_screens/ # Hizmet veren ekranları
│ ├── profile_screens/ # Profil alt sayfaları
│ └── ...
├── theme/ # Tema ve stil ayarları
└── main.dart # Uygulama giriş noktası


## ✨ Özellikler

### 👤 Evcil Hayvan Sahibi
- 🔍 Hizmet arama ve filtreleme
- ❤️ Favori hizmetleri kaydetme
- 📅 Randevu oluşturma
- 🐾 Evcil hayvan profili ekleme/düzenleme
- 📍 Adres ve konum seçimi (Google Maps)

### 🎯 Hizmet Veren
- 📊 Dashboard ve istatistikler
- 📋 Gelen ilanları görüntüleme
- 📅 Randevu yönetimi
- 💰 Kazanç takibi

### 👤 Ortak Özellikler
- 🔐 Kullanıcı girişi / kayıt ol
- 👤 Profil yönetimi ve resim yükleme
- 🔔 Bildirimler
- ❓ Yardım ve destek talebi
- 💳 Kayıtlı kartlar ve IBAN yönetimi

## 📸 Ekran Görüntüleri

*(Yakında eklenecek)*

## 🚀 Kurulum

### Gereksinimler
- Flutter SDK (3.16+)
- Dart SDK (3.2+)
- Android Studio / VS Code

### Adımlar

```bash
# 1. Projeyi klonlayın
git clone https://github.com/selinkincal/pet_care_app.git

# 2. Proje klasörüne gidin
cd pet_care_app

# 3. Paketleri yükleyin
flutter pub get

# 4. Uygulamayı çalıştırın
flutter run
