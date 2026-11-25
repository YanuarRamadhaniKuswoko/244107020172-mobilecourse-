# Week 14 – Deployment dan Monitoring (Deployment & Monitoring)

> **Jobsheet:** [#14 Deployment dan Monitoring](https://jti-polinema.github.io/flutter-codelab/14-minggu-14-deployment-monitoring/)  
> **Repository:** `14-week-14-deployment-monitoring/`

---

## 👨‍💻 Identitas Mahasiswa

| Informasi | Keterangan |
|---|---|
| **Nama** | Yanuar Ramadhani Kuswoko |
| **NIM** | 244107020172 |
| **Kelas / Absen** | TI-2D / 25 |
| **Mata Kuliah** | Pemrograman Mobile |
| **Minggu** | 14 – Deployment dan Monitoring |

---

## 🎯 Tujuan Pembelajaran

1. Menjelaskan alur kandidat rilis (*release candidate*) dari pipeline CI hingga tahapan pengujian beta terbatas.
2. Menyiapkan identitas versi aplikasi (`version: 1.0.0+21`) dan mengompilasi berkas Android App Bundle (AAB) release untuk keperluan pengujian internal.
3. Mengonfigurasi Firebase Crashlytics untuk penangkapan error fatal/non-fatal serta Firebase Analytics untuk pencatatan event penggunaan non-sensitif.
4. Meninjau sinyal telemetri rilis, menganalisis insiden crash, dan mengambil keputusan rilis (*go/no-go*) berdasarkan bukti yang terverifikasi.
5. Menerapkan etika dan prinsip tanggung jawab (*Responsible AI*) saat menyamarkan (*redact*) log sensitif sebelum dianalisis dengan AI.

---

## 📌 Ringkasan Pengerjaan Codelab Sesuai Panduan

Pengerjaan praktikum Minggu 14 dilakukan tepat dan terstruktur sesuai alur pada materi Jobsheet resmi tanpa menambahkan kode di luar panduan:

### 1. Menyiapkan Kandidat Rilis
- Menyesuaikan nomor versi dan build pada file `pubspec.yaml`:
  ```yaml
  version: 1.0.0+21
  ```
  `1.0.0` merupakan versi aplikasi yang terlihat oleh pengguna (*versionName*), sedangkan `21` adalah nomor build unik (*versionCode*).
- Menghubungkan kandidat rilis dengan tag Git `v1.0.0+21`.

### 2. Verifikasi Gerbang Kualitas Lokal
Menjalankan seluruh tahapan pemeriksaan sebelum berkas rilis diunggah:
```bash
flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze --fatal-infos
flutter test
flutter build appbundle --release
```

### 3. Konfigurasi Firebase Crashlytics & Analytics
- Menambahkan dependensi resmi Firebase:
  ```yaml
  dependencies:
    flutter:
      sdk: flutter
    firebase_core: ^5.2.0
    firebase_crashlytics: ^6.1.0
    firebase_analytics: ^13.1.0
  ```
- **Penanganan Crashlytics (`lib/main.dart`):**
  Mengimpor `dart:ui` untuk `PlatformDispatcher` dan mengarahkan seluruh error framework serta error asinkron ke Crashlytics:
  ```dart
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(
      error,
      stack,
      fatal: true,
    );
    return true;
  };
  ```
- **Pencatatan Event Analytics:**
  Mencatat interaksi umpan balik pengguna dengan parameter layar asal tanpa memuat data pribadi:
  ```dart
  await FirebaseAnalytics.instance.logEvent(
    name: 'beta_feedback_sent',
    parameters: {'screen_name': 'home'},
  );
  ```

### 4. Distribusi Pengujian Internal
- Memahami alur distribusi track **Internal Testing** di Google Play Console dengan menambahkan email tester resmi.
- Menggunakan alternatif **Firebase App Distribution** untuk pengujian privat build beta saat akses Play Console belum tersedia.

### 5. Laporan Rilis & Analisis Insiden
Dokumentasi lengkap mengenai rincian kandidat rilis, hasil pengujian, triage insiden crash `DetailPage.build -> Product.fromJson`, keputusan penahanan rilis (*halt rollout*), dan sanitasi log AI dituangkan dalam berkas [docs/release-report.md](file:///d:/mobile/14-week-14-deployment-monitoring/docs/release-report.md).

---

## 📊 Hasil Eksekusi Pemeriksaan Lokal

Semua langkah verifikasi lokal berhasil dieksekusi tanpa error di direktori `14-week-14-deployment-monitoring`:

### 1. Format Kode (`dart format`)
```bash
$ dart format --output=none --set-exit-if-changed .
Formatted 2 files (0 changed) in 0.03 seconds.
```
*Hasil: Format kode Dart 100% konsisten sesuai standar resmi.*

### 2. Analisis Statis Linter (`flutter analyze`)
```bash
$ flutter analyze --fatal-infos
Analyzing 14-week-14-deployment-monitoring...
No issues found! (ran in 9.0s)
```
*Hasil: Bersih dari warning, info, maupun error.*

### 3. Pengujian Unit & Widget (`flutter test`)
```bash
$ flutter test
00:00 +0: loading D:/mobile/14-week-14-deployment-monitoring/test/widget_test.dart
00:00 +0: Counter increments smoke test
00:01 +1: All tests passed!
```
*Hasil: Seluruh pengujian otomatis lulus.*

### 4. Kompilasi AAB Release (`flutter build appbundle --release`)
```bash
$ flutter build appbundle --release
Running Gradle task 'bundleRelease'...
√ Built build\app\outputs\bundle\release\app-release.aab (44.6MB)
```
*Hasil: Berkas bundel distribusi Android App Bundle berhasil dibuat.*

---

## 💡 Refleksi Codelab

### 1. Bukti apa yang diperlukan sebelum memperluas distribusi beta?
> **Jawaban:**  
> Sebelum memperluas jangkauan rilis dari Internal Testing ke Closed/Open Testing maupun Production, tim pengembang memerlukan bukti konkret berupa:
> - Metrik stabilitas tinggi dari Crashlytics dengan tingkat **Crash-Free Users / Sessions** minimal $\ge 99.5\%$.
> - Tidak adanya laporan crash fatal baru (*unhandled exceptions*) pada alur transaksi atau fitur utama.
> - Hasil pengujian fungsional dari penguji internal yang mewakili variasi perangkat fisik dan versi sistem operasi Android.
> - Tidak ditemukan kebocoran data, pemborosan baterai, maupun keluhan performa seperti freeze/ANR (*Application Not Responding*).

### 2. Bagaimana Anda memutuskan untuk menahan atau melanjutkan rilis?
> **Jawaban:**  
> - **Menahan Rilis (Halt/Halt Rollout):** Diputuskan apabila terdeteksi crash fatal yang merusak alur utama (misalnya crash parsing `Product.fromJson` saat membuka detail), ditemukannya kebocoran data sensitif/kredensial ke log, atau jika angka crash-free turun drastis di bawah ambang batas toleransi.
> - **Melanjutkan Rilis (Proceed/Promote):** Diputuskan apabila seluruh kriteria gerbang kualitas terpenuhi, issue yang dilaporkan pada versi sebelumnya terbukti selesai diperbaiki melalui unit test regresi, dan log telemetri membuktikan stabilitas aplikasi pada pengujian nyata.

### 3. Data apa yang tidak perlu dikirim ke layanan monitoring?
> **Jawaban:**  
> Data yang **TIDAK BOLEH** dikirimkan ke Crashlytics, Analytics, maupun log pemantauan meliputi:
> - **Informasi Identitas Pribadi (PII):** Nama lengkap, alamat email pribadi, nomor telepon, NIK, alamat rumah, atau data medis pengguna.
> - **Kredensial Keamanan:** Password, PIN, bearer token (JWT), API secret key, dan material signing keystore.
> - **Data Keuangan / Pembayaran:** Nomor kartu kredit/debit, kode CVV/CVC, dan informasi saldo akun pengguna.
> - **Konten Pribadi Pengguna:** Isi pesan chat rahasia atau berkas dokumen privat milik pengguna.

---

## 📸 Checklist Bukti Screenshot

Berikut daftar tangkapan layar (screenshot) yang perlu didokumentasikan ke dalam folder [14-week-14-deployment-monitoring/screenshots/](file:///d:/mobile/14-week-14-deployment-monitoring/screenshots/):

| No | Nama File Screenshot | Deskripsi Tangkapan Layar | Status |
|:---:|:---|---|:---:|
| 1 | `01_preflight_checks.png` | Terminal lokal yang memperlihatkan eksekusi perintah `dart format`, `flutter analyze --fatal-infos`, dan `flutter test` berhasil lulus 100%. | 📸 Siap diambil |
| 2 | `02_build_appbundle.png` | Terminal lokal yang memperlihatkan keberhasilan perintah `flutter build appbundle --release` menghasilkan `build/app/outputs/bundle/release/app-release.aab`. | 📸 Siap diambil |
| 3 | `03_internal_testing_track.png` | Tampilan konsol Google Play Console pada menu **Internal testing** (atau dasbor **Firebase App Distribution**) yang menampilkan rilis beta `1.0.0 (21)` siap diuji oleh grup tester. | 📸 Siap diambil |
| 4 | `04_crashlytics_dashboard.png` | Tampilan dasbor Firebase Crashlytics yang menampilkan metrik stabilitas *Crash-free users* dan status pemantauan versi aplikasi `1.0.0+21`. | 📸 Siap diambil |
| 5 | `05_analytics_events.png` | Tampilan dasbor Firebase Analytics (atau DebugView) yang memperlihatkan event non-sensitif `beta_feedback_sent` berhasil tercatat. | 📸 Siap diambil |
