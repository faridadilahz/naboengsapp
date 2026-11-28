# Naboengs — Aplikasi Pencatat & Pengingat Tabungan Target

> **Aplikasi Mobile Pencatat Target Tabungan Offline-First dengan Pengingat Harian Terjadwal**

## 1. Ringkasan Aplikasi & Desain Sistem

**Naboengs** adalah aplikasi mobile berbasis **Flutter** yang dirancang untuk membantu pengguna mencatat progres tabungan berdasarkan target tertentu secara mandiri tanpa ketergantungan server backend (*local-first*). Seluruh data tabungan, preferensi pengguna, dan jadwal pengingat diproses langsung di perangkat menggunakan penyimpanan lokal dan sistem alarm bawaan OS.

### Identitas Visual & Tipografi

Aplikasi mengusung tampilan bersih dengan aksen warna hijau toska dan tipografi **M PLUS Rounded 1c**:

* **Primary Green**: `#2EA98F`
* **Background Light**: `#FDFFFF` / `#FFFFFF`
* **Danger / Delete**: `#D0505C`
* **Native Splash Screen (Adaptive)**:
  * *Light Mode*: Background `#FFFFFF` dengan logo hijau (`logosplash.png`)
  * *Dark Mode*: Background `#1B1B1B` dengan logo putih (`logosplashdark.png`)

## 2. Fitur Utama

1. **Manajemen Target Tabungan**:
   * Membuat target tabungan baru lengkap dengan nama target, nominal tujuan, dan foto ilustrasi dari galeri (`image_picker`).
   * Menambah atau mengurangi nominal tabungan secara bertahap, melihat detail, mengedit, atau menghapus tabungan.
   * Pemisahan otomatis tabungan ke dalam dua tab status: **Dalam Proses** dan **Tercapai** (diurutkan berdasarkan pembaruan terakhir).
   * Efek selebrasi (`confetti`) saat nominal terkumpul mencapai atau melampaui target.

2. **Personalisasi Pengguna**:
   * Sapaan dinamis di beranda yang menyesuaikan waktu perangkat (Pagi, Siang, Sore, Malam).
   * Pengaturan nama pengguna saat pertama kali membuka aplikasi maupun melalui tombol edit di header.

3. **Sistem Notifikasi Lokal Cerdas (`NotificationService`)**:
   * Berjalan 100% lokal tanpa server (*push notification* berbasis `AlarmManager` / `UNUserNotificationCenter`).
   * **Notifikasi Tabungan Pertama**: Pengingat instan khusus ketika pengguna membuat kartu tabungan untuk pertama kalinya.
   * **Pengingat Harian (13:00 & 19:00)**: Mengirimkan pesan pengingat dengan variasi kalimat santai yang diacak setiap sesi.
   * **Pembatalan Otomatis Harian**: Jika pengguna sudah menambahkan nominal ke dalam tabungan pada hari tersebut, pengingat jam 13:00 dan 19:00 untuk hari itu otomatis dibatalkan dan digeser ke hari berikutnya.
   * **Alur Izin Dinamis**: Izin notifikasi diminta setelah *splash screen* (atau setelah dialog input nama pada pengguna baru). Jika ditolak/diabaikan, permintaan izin akan dimunculkan kembali pada pembuatan tabungan ke-3, ke-6, ke-9, dan kelipatan 3 seterusnya.

## 3. Struktur Proyek & Arsitektur

Seluruh logika bisnis, penyimpanan, dan layanan notifikasi diisolasi di dalam direktori `lib/`:

```text
lib/
├── models/
│   └── tabungan_model.dart             # Model data & serialisasi JSON tabungan
├── screens/
│   ├── add_tabungan_screen.dart        # Form pembuatan target tabungan baru
│   ├── detail_tabungan_screen.dart     # Halaman rincian & riwayat progres tabungan
│   ├── edit_tabungan_screen.dart       # Form ubah informasi target tabungan
│   └── home_screen.dart                # Layar utama, manajemen state, & alur izin
├── services/
│   ├── api_service.dart                # Layanan komunikasi data / API
│   └── notification_service.dart       # Singleton layanan jadwal & izin notifikasi lokal
├── utils/
│   ├── app_colors.dart                 # Konstanta palet warna aplikasi
│   ├── format_rupiah.dart              # Helper pemformatan teks mata uang Rupiah
│   └── rupiah_formatter.dart           # TextInputFormatter otomatis nominal Rupiah
├── widgets/
│   ├── celebration_dialog.dart         # Dialog selebrasi confetti saat target tercapai
│   ├── edit_nominal_dialog.dart        # Dialog ubah nominal saldo tabungan
│   ├── empty_state.dart                # Tampilan ilustrasi saat daftar tabungan kosong
│   ├── input_nama.dart                 # Dialog input & edit nama pengguna
│   ├── preview_nominal_dialog.dart     # Dialog pratinjau perubahan nominal
│   ├── selector.dart                   # Komponen pemilih opsi umum
│   ├── tab_bar.dart                    # Navigasi tab Dalam Proses & Tercapai
│   ├── tabungan_card.dart              # Kartu ringkasan progres per item tabungan
│   ├── tabungan_image.dart             # Komponen penampil gambar/foto tabungan
│   ├── tabungan_list_view.dart         # Daftar gulir kartu tabungan
│   ├── tambah_kurang_selector.dart     # Toggle mode tambah atau kurangi nominal
│   └── tambah_nominal_dialog.dart      # Dialog input tambah/kurang saldo tabungan
└── main.dart                           # Entry point & inisialisasi NotificationService
```

### Penyimpanan Data (`SharedPreferences`)

Data disimpan secara lokal dalam format JSON dan *key-value*:

* `data_tabungan`: Daftar seluruh objek tabungan.
* `nama_pengguna`: Nama panggilan pengguna.
* `tanggal_terakhir_nabung`: Penanda tanggal (`YYYY-MM-DD`) untuk membatalkan pengingat harian jika sudah menabung.
* `total_tabungan_dibuat` & `sudah_notif_tabungan_pertama`: Pelacak milestone pembuatan tabungan untuk logika izin kelipatan 3 dan notifikasi pertama.

## 4. Tech Stack & Dependensi Utama

* **Framework**: Flutter (Dart SDK `^3.9.2`)
* **Penyimpanan Lokal**: `shared_preferences`
* **Notifikasi & Zona Waktu**: `flutter_local_notifications`, `timezone`
* **Izin Sistem**: `permission_handler`
* **Media & UI**: `image_picker`, `confetti`, `ionicons`, `flutter_svg`, `material_ui`
* **Asset Generator**: `flutter_native_splash`, `flutter_launcher_icons`

## 5. Petunjuk Instalasi & Menjalankan Proyek (Developer)

### Kebutuhan Sistem:

* Flutter SDK (`^3.9.2`)
* Android Studio / Xcode (untuk build target Android atau iOS)
* Perangkat fisik atau emulator (Android 13+ disarankan untuk menguji izin runtime notifikasi & exact alarm)

### Langkah Setup:

```bash
# 1. Clone repositori
git clone <url-repositori-naboengs>
cd naboengs

# 2. Unduh seluruh dependensi
flutter pub get

# 3. Generate ikon aplikasi & native splash screen
dart run flutter_launcher_icons
dart run flutter_native_splash:create

# 4. Jalankan aplikasi di perangkat terhubung
flutter run
```

### Build Release APK (Ukuran Ramping):

```bash
flutter build apk --release --split-per-abi
```

## 6. Panduan Unduh & Instalasi Aplikasi (Pengguna Akhir)

Aplikasi **Naboengs** didistribusikan melalui halaman web resmi (**naboengs-installation**) dengan langkah pemasangan yang berbeda sesuai sistem operasi perangkat:

### Perangkat Android (via File `.apk`)

1. Buka halaman unduhan **Naboengs** melalui browser di ponsel Android (Chrome / Samsung Internet).
2. Ketuk tombol **Download APK** untuk mengunduh berkas `naboengs.apk`.
3. Jika muncul peringatan browser *"File mungkin berbahaya"*, pilih **Tetap download** (*Download anyway*).
4. Buka berkas `naboengs.apk` yang telah selesai diunduh melalui notifikasi atau folder **Download** di File Manager.
5. Jika diminta izin pemasangan dari sumber tidak dikenal, ketuk **Setelan** (*Settings*) $\rightarrow$ aktifkan **Izinkan dari sumber ini** (*Allow from this source*), lalu kembali.
6. Ketuk **Install** dan tunggu hingga proses pemasangan selesai.
7. Buka aplikasi **Naboengs**, lalu pilih **Izinkan** (*Allow*) saat muncul pop-up izin notifikasi agar pengingat menabung harian aktif.

### Perangkat iOS / iPhone

Sistem operasi iOS tidak mendukung pemasangan berkas `.apk` secara langsung. Pengguna iPhone/iPad dapat memasang Naboengs melalui salah satu metode berikut:

* **Metode 1 — Web App (*Add to Home Screen* via Safari):**
  1. Buka tautan versi Web **Naboengs** menggunakan browser **Safari**.
  2. Ketuk ikon **Share** (kotak dengan panah ke atas) di bilah navigasi bawah.
  3. Gulir ke bawah dan pilih **Add to Home Screen** (*Tambah ke Layar Utama*).
  4. Ketuk **Add** (*Tambah*) di pojok kanan atas agar ikon Naboengs terpasang di layar utama.

* **Metode 2 — Build Native iOS (TestFlight / Sideload `.ipa`):**
  1. **Via TestFlight**: Unduh aplikasi **TestFlight** dari App Store, buka tautan undangan Naboengs, lalu ketuk **Install**.
  2. **Via Sideloading (`naboengs.ipa`)**: Pasang berkas `.ipa` menggunakan AltStore atau Sideloadly, kemudian buka **Settings $\rightarrow$ General $\rightarrow$ VPN & Device Management** di iPhone dan ketuk **Trust** pada profil pengembang sebelum membuka aplikasi.

## 7. Catatan Teknis & Platform

1. **Android 12+ & 13+**:
   * Konfigurasi splash screen Android 12+ diatur terpisah di blok `android_12` pada `flutter_native_splash.yaml`.
   * `AndroidManifest.xml` telah dilengkapi `POST_NOTIFICATIONS`, `SCHEDULE_EXACT_ALARM`, `RECEIVE_BOOT_COMPLETED`, serta `ScheduledNotificationReceiver` agar jadwal tetap berjalan meski aplikasi ditutup.
   * Pada perangkat dengan manajemen baterai agresif (seperti Xiaomi MIUI/HyperOS), atur penghemat baterai aplikasi ke *"Tidak ada pembatasan"* agar alarm tepat waktu.

2. **Konfigurasi iOS**:
   * `ios/Runner/Info.plist` memerlukan `NSPhotoLibraryUsageDescription` dan `NSCameraUsageDescription` untuk fitur pilih foto tabungan.
   * `ios/Runner/AppDelegate.swift` menggunakan `UNUserNotificationCenter` delegate agar banner notifikasi tetap tampil saat aplikasi berada di *foreground*.