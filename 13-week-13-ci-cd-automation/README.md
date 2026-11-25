# Week 13 – CI/CD dan Otomatisasi (CI/CD Automation)

> **Jobsheet:** [#13 CI/CD dan Otomatisasi](https://jti-polinema.github.io/flutter-codelab/13-minggu-13-ci-cd-automation/)  
> **Repository:** `13-week-13-ci-cd-automation/`

---

## 👨‍💻 Identitas Mahasiswa

| Informasi | Keterangan |
|---|---|
| **Nama** | Yanuar Ramadhani Kuswoko |
| **NIM** | 244107020172 |
| **Kelas / Absen** | TI-2D / 25 |
| **Mata Kuliah** | Pemrograman Mobile |
| **Minggu** | 13 – CI/CD dan Otomatisasi |

---

## 🎯 Tujuan Pembelajaran

1. Menjelaskan alur CI/CD dari proses commit kode sumber hingga dihasilkannya artefak aplikasi yang siap diuji.
2. Membuat workflow otomatisasi GitHub Actions untuk menjalankan format kode, analisis statis, pengujian otomatis, dan proses build aplikasi Android.
3. Menyimpan file APK dan AAB hasil build sebagai artefak build di GitHub Actions yang dapat ditinjau dan diunduh.
4. Menerapkan konvensi versioning (Semantic Versioning) dan memahami batasan keamanan penyimpanan secrets serta variabel lingkungan pada aplikasi mobile.

---

## 📌 Ringkasan Pengerjaan Codelab Sesuai Panduan

Seluruh implementasi pada praktikum Minggu 13 ini dikerjakan secara presisi mengikuti panduan Codelab resmi tanpa menambahkan kode di luar instruksi jobsheet:

### 1. Persiapan Project
- Menyiapkan project Flutter dengan minimal satu pengujian otomatis yang berjalan dan lulus secara lokal (`test/widget_test.dart`).
- Mengatur konfigurasi branch Git utama (`main`).

### 2. Memahami CI/CD dan Alur Kerja
- **Continuous Integration (CI):** Mengotomatiskan validasi kualitas kode setiap kali pengembang melakukan `push` atau mengajukan `pull_request`.
- **Continuous Delivery/Deployment (CD):** Mengotomatiskan pembuatan build rilis (APK/AAB) setelah seluruh tahapan verifikasi kualitas kode terpenuhi.
- **Prinsip Least Privilege & Keamanan:** Memberikan izin minimum pada workflow dengan `permissions: contents: read`. Mengamankan repository dengan tidak mengekspos secrets ke pull request fork.

### 3. File Workflow CI/CD (`.github/workflows/flutter-ci.yml`)
Workflow GitHub Actions disusun sesuai spesifikasi jobsheet:

```yaml
name: Flutter CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
  workflow_dispatch:

permissions:
  contents: read

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  test-and-build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
      - run: flutter pub get
      - run: dart format --output=none --set-exit-if-changed .
      - run: flutter analyze --fatal-infos
      - run: flutter test --coverage
      - run: flutter build apk --release
      - run: flutter build appbundle --release
      - uses: actions/upload-artifact@v4
        with:
          name: android-builds
          path: |
            build/app/outputs/flutter-apk/app-release.apk
            build/app/outputs/bundle/release/app-release.aab
          if-no-files-found: error
          retention-days: 7
```

**Penjelasan Bagian Workflow:**
- **Trigger Event (`on`):**
  - `push: branches: [main]`: Berjalan otomatis saat ada commit baru yang di-push ke branch utama.
  - `pull_request: branches: [main]`: Berjalan saat pull request dibuat atau diperbarui ke branch utama.
  - `workflow_dispatch`: Memungkinkan eksekusi pipeline secara manual langsung dari antarmuka GitHub Actions.
- **Concurrency:** `cancel-in-progress: true` membatalkan antrean run lama yang belum selesai jika ada commit baru yang masuk pada branch yang sama, menghemat waktu dan kuota runner.
- **Runner OS:** `ubuntu-latest` menyediakan environment Linux virtual yang bersih, cepat, dan terisolasi.
- **Actions Setup:**
  - `actions/checkout@v4`: Mengambil source code repository ke lingkungan runner.
  - `subosito/flutter-action@v2`: Mempersiapkan Flutter SDK pada channel `stable`.
- **Verifikasi Kualitas:**
  - `flutter pub get`: Mengunduh seluruh dependensi paket yang didefinisikan pada `pubspec.yaml`.
  - `dart format --output=none --set-exit-if-changed .`: Memeriksa apakah seluruh file Dart sudah diformat rapi sesuai standar resmi. Mengembalikan exit code non-zero jika ditemukan file yang belum terformat.
  - `flutter analyze --fatal-infos`: Melakukan analisis statis menyeluruh. Opsi `--fatal-infos` memastikan bahwa info linting diperlakukan sebagai kegagalan build agar standar kode tetap ketat.
  - `flutter test --coverage`: Menjalankan suite test dan menghasilkan laporan cakupan kode (`coverage/lcov.info`).
- **Build & Simpan Artefak:**
  - `flutter build apk --release`: Menghasilkan berkas APK release untuk keperluan pengujian internal di perangkat fisik Android.
  - `flutter build appbundle --release`: Menghasilkan berkas AAB release untuk distribusi Play Store.
  - `actions/upload-artifact@v4`: Mengunggah kedua berkas rilis tersebut sebagai artefak dengan nama `android-builds` dan masa simpan (*retention*) selama 7 hari.

---

## 📊 Hasil Eksekusi Pemeriksaan Lokal

Sebelum kode di-push ke GitHub, pemeriksaan mandiri dilakukan secara lokal di direktori `13-week-13-ci-cd-automation`:

### 1. Format Kode (`dart format`)
```bash
$ dart format --output=none --set-exit-if-changed .
Formatted 2 files (0 changed) in 0.01 seconds.
```
*Hasil: Seluruh berkas kode Dart telah mematuhi pedoman format resmi Dart.*

### 2. Analisis Statis Linter (`flutter analyze`)
```bash
$ flutter analyze --fatal-infos
Analyzing 13-week-13-ci-cd-automation...
No issues found! (ran in 18.1s)
```
*Hasil: Nol peringatan, nol error, dan nol saran info (clean analysis).*

### 3. Pengujian Otomatis dan Cakupan Kode (`flutter test --coverage`)
```bash
$ flutter test --coverage
00:00 +0: loading D:/mobile/13-week-13-ci-cd-automation/test/widget_test.dart
00:00 +0: Counter increments smoke test
00:01 +1: All tests passed!
```
*Hasil: Semua pengujian otomatis lulus 100%.*

### 4. Build APK Release (`flutter build apk --release`)
```bash
$ flutter build apk --release
Running Gradle task 'assembleRelease'...
√ Built build\app\outputs\flutter-apk\app-release.apk (42.1MB)
```
*Hasil: Berkas biner APK Android berhasil dikompilasi.*

### 5. Build Android App Bundle Release (`flutter build appbundle --release`)
```bash
$ flutter build appbundle --release
Running Gradle task 'bundleRelease'...
√ Built build\app\outputs\bundle\release\app-release.aab (42.2MB)
```
*Hasil: Berkas bundel distribusi Play Store (AAB) berhasil dikompilasi.*


---

## 📝 Dokumentasi Tugas Codelab

### 1. Versioning Aplikasi (Semantic Versioning)
Konfigurasi versi aplikasi diatur pada file `pubspec.yaml`:
```yaml
version: 1.0.0+1
```
- **Versi Aplikasi saat ini:** `1.0.0` dengan build number `1`.
- **Rencana Versi Berikutnya:**
  - **Patch Release (`1.0.1+2`):** Untuk perbaikan bug kecil yang tidak mengubah fungsionalitas dan kompatibel ke belakang.
  - **Minor Feature Release (`1.1.0+2`):** Untuk penambahan fitur baru yang tetap menjaga kompatibilitas ke belakang (*backward-compatible*).
  - **Major Breaking Release (`2.0.0+2`):** Untuk perubahan arsitektur besar atau pembaruan yang mengubah API / alur penggunaan secara signifikan.
- **Git Tagging:** Setiap versi rilis yang telah lulus pipeline diberi tag Git yang sesuai, contoh: `git tag v1.0.0`.

### 2. Manajemen Secrets dan Mitigasi Risiko Keamanan
- **GitHub Secrets:** Kredensial sensitif seperti keystore signing release Android (base64 encoded keystore), alias password, dan key password tidak boleh disimpan di source code repository. Kredensial tersebut wajib disimpan pada **Settings > Secrets and variables > Actions** di GitHub repository.
- **Batasan `--dart-define`:** Nilai variabel yang dimasukkan lewat opsi compile `--dart-define` akan dikompilasi langsung ke dalam biner aplikasi klien (DEX/APK). Siapapun dapat mengekstrak nilai tersebut dengan teknik reverse engineering / dekompilasi APK. Oleh karena itu, `--dart-define` hanya cocok untuk konfigurasi publik (seperti URL Base API, nama environment), bukan untuk kunci privat atau password database.
- **Fork Pull Request Protection:** Pull request yang berasal dari repositori fork publik secara otomatis dibatasi aksesnya oleh GitHub Actions terhadap secrets repositori utama, mencegah kebocoran kredensial dari kontributor luar.

---

## 💡 Refleksi Codelab

### 1. Masalah apa yang ditemukan otomatis sebelum perubahan di-merge?
> **Jawaban:**  
> Pipeline CI secara otomatis mendeteksi masalah-masalah berikut sebelum kode digabungkan (*merge*) ke branch utama:
> - **Kesalahan Sintaks dan Tipe Data:** Kesalahan penulisan kode atau ketidakcocokan tipe yang luput saat pengkodean lokal langsung tertangkap oleh compiler.
> - **Pelanggaran Standar Kode:** Gaya penulisan yang tidak konsisten atau pelanggaran linter tertangkap oleh `dart format` dan `flutter analyze --fatal-infos`.
> - **Regresi Fungsional (Broken Tests):** Fitur baru yang merusak logika yang sudah ada sebelumnya akan menyebabkan `flutter test` gagal, sehingga pull request yang bermasalah tidak dapat di-merge.
> - **Kegagalan Build Android:** Masalah dependensi native Gradle, konflik plugin, atau resource Android yang hilang terdeteksi pada langkah `flutter build apk` dan `flutter build appbundle`.

### 2. Informasi apa yang Anda butuhkan untuk menyelidiki build yang gagal?
> **Jawaban:**  
> - **Log Keluaran Step yang Gagal:** Meninjau secara spesifik baris log error pada step GitHub Actions yang berwarna merah (misal baris stacktrace pada `flutter test` atau failure message pada `flutter analyze`).
> - **Identitas Commit & Diff Perubahan:** Melihat hash commit, pesan commit, author, dan perbandingan kode (*diff*) yang memicu eksekusi workflow tersebut.
> - **Versi Environment & Dependensi:** Mengetahui versi Flutter SDK, versi Dart, channel SDK yang digunakan runner, serta dependency tree dari `pubspec.lock`.
> - **Log Sistem Build Native Gradle:** Pada kegagalan build Android, log error dari Gradle (seperti `task ':app:compileFlutterBuildRelease' failed`) memberikan petunjuk konfigurasi SDK Android, Java JDK, atau kompatibilitas Android Gradle Plugin (AGP).

### 3. Bagian mana yang masih perlu persetujuan atau pemeriksaan manual sebelum rilis?
> **Jawaban:**  
> Meskipun CI/CD mengotomatiskan validasi teknis dan build biner, persetujuan dan pemeriksaan manual tetap krusial pada bagian-bagian berikut:
> - **Pengujian Pengalaman Pengguna (User Experience / QA Testing):** Uji coba langsung di berbagai perangkat fisik dengan beragam ukuran layar, orientasi, dan versi OS untuk memvalidasi kenyamanan antarmuka dan respon sentuhan pengguna (*look and feel*).
> - **Pemeriksaan Kepatuhan dan Kebijakan Rilis:** Verifikasi dokumen kebijakan privasi, izin perangkat (*permissions* seperti kamera, lokasi), dan kesesuaian konten dengan pedoman Google Play Developer Policy.
> - **Persetujuan Final Rilis (Release Gate Approval):** Keputusan bisnis dari Product Owner / Tim Rilis mengenai waktu peluncuran, penulisan *Release Notes* (catatan rilis versi), serta peluncuran bertahap (*staged rollout* 10%, 50%, 100%) ke pengguna umum di Play Store.

---

## 📸 Checklist Bukti Screenshot

Berikut adalah panduan tangkapan layar (screenshot) yang perlu didokumentasikan ke folder `13-week-13-ci-cd-automation/screenshots/`:

| No | Nama File Screenshot | Deskripsi Tangkapan Layar | Status |
|:---:|:---|---|:---:|
| 1 | `01_local_checks_passed.png` | Terminal lokal yang menunjukkan perintah `dart format`, `flutter analyze --fatal-infos`, dan `flutter test --coverage` berhasil lulus (*zero issues / all passed*). | 📸 Siap diambil |
| 2 | `02_git_push_commit.png` | Terminal atau git GUI yang menunjukkan commit dan push workflow ke branch `main` GitHub repository. | 📸 Siap diambil |
| 3 | `03_github_actions_tab.png` | Tampilan halaman tab **Actions** di GitHub repository yang menunjukkan workflow *Flutter CI* berjalan dan berstatus checklist hijau (Success). | 📸 Siap diambil |
| 4 | `04_job_steps_detail.png` | Tampilan detail log langkah-langkah job `test-and-build` di GitHub Actions yang seluruhnya centang hijau (Checkout, Flutter setup, format, analyze, test, build apk/aab, upload artifact). | 📸 Siap diambil |
| 5 | `05_artifact_android_builds.png` | Tampilan bagian **Artifacts** pada halaman rangkuman run workflow yang menampilkan artefak `android-builds` (berisi APK dan AAB) siap untuk diunduh. | 📸 Siap diambil |
