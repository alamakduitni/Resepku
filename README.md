# Resepku - Aplikasi Resep Makanan

Aplikasi mobile berbasis Flutter untuk menjelajahi berbagai resep makanan dan minuman, dibuat sebagai proyek tugas kuliah dengan fokus penerapan `StatelessWidget` yang tepat sesuai kebutuhan tiap komponen.

## Anggota Kelompok

| No | Nama | NIM |
|---|---|---|
| 1 | Rafi Ramadhana Bukaryo | 24051214180 |
| 2 | Danella Andritya Putri | 24051214205 |
| 3 | Haikal Ahmad El Salman | 24051214207 |
| 4 | Revo Novandra | 24051214211 |

## Fitur

- **Splash Screen** - animasi koki memasak
- **Onboarding** - 3 halaman perkenalan fitur, swipeable
- **Login & Register** - alur autentikasi dengan data dummy
- **Homepage**
  - Carousel gambar makanan 
  - Kategori makanan
  - Rekomendasi resep trending
- **Detail Resep** - bahan-bahan, langkah pembuatan, rating, profil uploader
- **Search** - kategori makanan & minuman
- **Favorite** - daftar resep favorit
- **Profile** - data diri pengguna
- **Tambah Resep** - halaman placeholder ("Fitur Akan Segera Hadir")

## Tech Stack

- **Flutter** & **Dart**
- **Android Studio** - Android Emulator
- **Material Symbols Rounded** - icon set
- **Font Inter** - typography

## Struktur Project

```
lib/
├── main.dart
├── app.dart
├── core/           # constants (warna, icon, text style), theme, utils
├── data/           # models & dummy data (JSON lokal)
├── screens/        # semua halaman aplikasi
├── widgets/        # widget yang dipakai lintas halaman
└── routes/         # konfigurasi navigasi
```

## Catatan Teknis

- Tidak ada backend - seluruh data bersumber dari dummy data (JSON lokal)
- Tidak ada persistence - state akan reset saat aplikasi ditutup/dibuka ulang
- State management memakai `setState()` lokal, tanpa Provider/Riverpod/Bloc

## Cara Menjalankan

```bash
git clone <url-repo-ini>
cd masak
flutter pub get
flutter run
```
