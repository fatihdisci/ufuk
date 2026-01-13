# 🌅 UFUK (Horizon)

**Minimalist namaz vakti ve Ramazan yardımcı uygulaması.**

Günün ritmini bozmadan, huzurlu bir deneyimle namaz vakitlerini takip edin.

---

## ✨ Özellikler

### 🕌 Namaz Vakitleri
- Türkiye'nin **81 ili ve 900+ ilçesi** için doğru vakitler
- Diyanet hesaplama metodu (Aladhan API)
- **Offline destek**: Veriler otomatik önbelleğe alınır

### 📖 Günün İlhamı
- Her gün farklı **ayet ve hadis**
- **15 tema** ile zenginleştirilmiş içerik: Sabır, Şükür, Dua, Tevekkül, Merhamet...
- Günün temasına uygun içerik seçimi

### 🎨 Premium Tasarım
- **Glassmorphism** cam efekti kartlar
- Vakite göre değişen **ambient arka plan gradyanları**
- Büyük, okunaklı **geri sayım** (72px)
- Tek sayfa, sıfır karmaşa

### 🔒 Gizlilik Öncelikli
- GPS izni **gerektirmez** — konum manuel seçilir
- Konum tercihi cihazda saklanır
- Üçüncü taraflarla veri paylaşımı yok

### 🌙 Ramazan Modu
- Otomatik Ramazan tespiti (Hicri takvim)
- "Sahura Kalan" / "İftara Kalan" özel etiketler
- **Huzur Vakti**: İftara 15 dakika kala reklamsız deneyim

---

## 📱 Ekran Görüntüleri

| Ana Ekran | Konum Seçimi |
|-----------|--------------|
| Geri sayım + Günün teması | 81 il + ilçeler |

---

## 🛠 Teknoloji

| Katman | Teknoloji |
|--------|-----------|
| **Framework** | Flutter 3.x (Dart) |
| **State Management** | ValueNotifier (Vanilla) |
| **Veri Kaynağı** | [Aladhan API](https://aladhan.com/prayer-times-api) |
| **Önbellekleme** | Hive (NoSQL) |
| **Tasarım** | Google Fonts (Outfit, Playfair Display) |
| **Reklam** | Google Mobile Ads (Native + Interstitial) |

---

## 🚀 Kurulum

### Gereksinimler
- Flutter SDK 3.10+
- Android Studio / VS Code
- Android Emulator veya fiziksel cihaz

### Adımlar

```bash
# 1. Repo'yu klonla
git clone https://github.com/fatihdisci/ufuk.git
cd ufuk

# 2. Bağımlılıkları yükle
flutter pub get

# 3. Uygulamayı çalıştır
flutter run
```

---

## 📂 Proje Yapısı

```
lib/
├── app/                    # Tema & Atmosfer
│   ├── atmosphere/         # Gradient engine
│   └── theme/              # Glass tokens
├── common/                 # Paylaşılan widget'lar
├── data/                   # Veri katmanı
│   ├── local/              # Hive cache
│   ├── repository/         # Data orchestration
│   └── services/           # API, Location, Ads
├── domain/                 # İş mantığı
│   └── engine/             # Countdown, Context
└── features/               # Ekranlar
    ├── home/               # Ana ekran
    └── settings/           # Konum seçici
```

---

## 🎯 Tasarım Felsefesi

> *"Huzur veren bir uygulama, dikkat dağıtmamalı."*

- **Ambient-First**: Arka plan vakitle birlikte nefes alır
- **Zero-Friction**: Tek sayfa, geçiş yok, yükleme yok
- **Respect**: Kullanıcının zamanına ve dikkatine saygı

---

## 📄 Lisans

Bu proje kişisel kullanım içindir.

---

## 👨‍💻 Geliştirici

**Fatih Dişçi**

- GitHub: [@fatihdisci](https://github.com/fatihdisci)

---

<p align="center">
  <i>Günün ritmini boz<b>ma</b>, huzuru bul.</i>
</p>
