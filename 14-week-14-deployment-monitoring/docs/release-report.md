# 📋 Release Report: Beta Candidate v1.0.0+21

> **Project:** `14-week-14-deployment-monitoring`  
> **Jobsheet:** [#14 Deployment dan Monitoring](https://jti-polinema.github.io/flutter-codelab/14-minggu-14-deployment-monitoring/)  
> **Tanggal Rilis:** 25 November 2026  
> **Penyusun:** Yanuar Ramadhani Kuswoko (NIM: 244107020172 / TI-2D / 25)

---

## 1. 📌 Metadata Kandidat Rilis (Release Candidate Metadata)

| Properti | Nilai / Keterangan |
|---|---|
| **Nama Aplikasi** | `deployment_monitoring` (Deployment & Monitoring) |
| **Versi Aplikasi (Version Name)** | `1.0.0` |
| **Nomor Build (Version Code)** | `21` (`version: 1.0.0+21`) |
| **Git Tag / Commit** | `v1.0.0+21` / `main` |
| **Format Artefak** | Android App Bundle (`.aab`) |
| **Path Artefak Build** | `build/app/outputs/bundle/release/app-release.aab` |
| **Ukuran Artefak** | ~44.6 MB |
| **Track Distribusi** | Google Play Console - *Internal Testing* (Alternatif: *Firebase App Distribution*) |
| **Audiens Penguji** | Tim QA & Penguji Terbatas (Internal Tester Group) |

---

## 2. 🧪 Hasil Pemeriksaan Pra-Rilis (Pre-flight Verification)

Sebelum pembuatan rilis AAB, seluruh gerbang pemeriksaan otomatis wajib lulus tanpa pengecualian:

### A. Dependensi & Resolusi Paket
```bash
$ flutter pub get
Resolving dependencies...
Got dependencies.
```
*Status: Sukses, seluruh dependensi (`firebase_core`, `firebase_crashlytics`, `firebase_analytics`) terinstal.*

### B. Format Kode Dart
```bash
$ dart format --output=none --set-exit-if-changed .
Formatted 2 files (0 changed) in 0.03 seconds.
```
*Status: Lulus, seluruh baris kode mematuhi panduan format resmi Dart.*

### C. Analisis Statis Linter
```bash
$ flutter analyze --fatal-infos
Analyzing 14-week-14-deployment-monitoring...
No issues found! (ran in 9.0s)
```
*Status: Lulus, nol warning, nol info, nol error.*

### D. Pengujian Otomatis
```bash
$ flutter test
00:00 +0: loading D:/mobile/14-week-14-deployment-monitoring/test/widget_test.dart
00:00 +0: Counter increments smoke test
00:01 +1: All tests passed!
```
*Status: Lulus 100%.*

### E. Kompilasi Android App Bundle (Release)
```bash
$ flutter build appbundle --release
Running Gradle task 'bundleRelease'...
√ Built build\app\outputs\bundle\release\app-release.aab (44.6MB)
```
*Status: Berkas AAB berhasil dikompilasi dan siap didistribusikan ke track pengujian internal.*

---

## 3. 📡 Konfigurasi Monitoring & Telemetri

### A. Firebase Crashlytics (Pelaporan Crash Fatal & Non-Fatal)
Inisialisasi dilakukan pada awal fungsi `main()` di `lib/main.dart`:
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
- **Error Flutter Framework:** Ditangkap oleh `FlutterError.onError` dan diteruskan secara otomatis ke Crashlytics sebagai fatal error.
- **Error Asinkron / Platform:** Ditangkap melalui `PlatformDispatcher.instance.onError` dari pustaka `dart:ui`, menjamin exception yang tidak tertangani di background thread tetap terlapor.

### B. Firebase Analytics (Event Non-Sensitif)
Pencatatan aktivitas pengguna untuk mengevaluasi adopsi fitur beta:
```dart
await FirebaseAnalytics.instance.logEvent(
  name: 'beta_feedback_sent',
  parameters: {'screen_name': 'home'},
);
```
- **Nama Event:** `beta_feedback_sent`
- **Parameter:** `{'screen_name': 'home'}` (lokasi layar asal pengiriman umpan balik).
- **Prinsip Privasi:** Tidak mengirim teks pesan pengguna, identitas pribadi (PII), email, token otorisasi, atau koordinat lokasi GPS.

---

## 4. 👥 Rencana & Hasil Pengujian Pengguna (Tester Feedback)

### A. Skenario Pengujian Tester
1. Tester menerima undangan melalui email terdaftar di Google Play Internal Testing atau tautan opt-in Firebase App Distribution.
2. Tester menginstal aplikasi `v1.0.0+21` pada perangkat fisik Android (Android 12/13/14).
3. Melakukan pengetesan alur utama:
   - Pembukaan aplikasi awal.
   - Pengecekan rendering judul "Beta Candidate v1.0.0+21".
   - Menekan FloatingActionButton untuk menaikkan counter.
   - Menekan tombol "Send Beta Feedback" untuk menguji pemicu event telemetri.
   - Memastikan aplikasi tidak mengalami lag, freeze (ANR), atau crash tiba-tiba.

### B. Log Pengujian Tester

| ID Penguji | Perangkat / OS | Skenario | Hasil yang Diharapkan | Hasil Aktual | Status |
|:---:|:---|---|---|---|:---:|
| T-01 | Pixel 7 (Android 14) | Navigasi Beranda & Counter | Counter bertambah secara mulus | Counter bertambah normal | ✅ Lulus |
| T-02 | Samsung S22 (Android 13) | Kirim Feedback Telemetri | Event terkirim tanpa blocking UI | Tombol feedback responsif | ✅ Lulus |
| T-03 | Xiaomi Redmi Note (Android 12) | Uji Stabilitas Latar Belakang | Aplikasi resume tanpa error | Memori stabil, tidak crash | ✅ Lulus |

---

## 5. 🔍 Analisis Insiden & Triage Rilis (Incident Analysis & Triage)

Berdasarkan studi kasus pemantauan rilis beta `1.0.0+21`:

### A. Rincian Masalah
- **Pesan Error:** `type 'Null' is not a subtype of type 'String'`
- **Lokasi Stack Trace:** `DetailPage.build` $\rightarrow$ `Product.fromJson`
- **Gejala:** Crash fatal seketika saat tester membuka layar detail produk tertentu.

### B. Investigasi & Akar Masalah
- **Penyebab:** Pada respon API backend untuk beberapa produk baru, field `'description'` bernilai `null`. Model `Product.fromJson` mengharapkan tipe data `String` non-nullable tanpa nilai fallback.
- **Kategori Dampak:** **Critical (P0)** — Memblokir alur utama penggunaan aplikasi bagi pengguna yang melihat detail produk.

### C. Keputusan Rilis (Release Decision)
> **KEPUTUSAN: TAHAN DISTRIBUSI (HALT ROLLOUT)**  
> **Alasan:** Ditemukan regresi crash fatal pada alur utama yang berdampak langsung pada pengguna. Distribusi beta tidak boleh diperluas ke track Open Testing atau Production sampai perbaikan selesai divalidasi.

### D. Rencana Perbaikan (Remediation Plan)
1. **Perbaikan Kode:**
   ```dart
   // Sebelum:
   description: json['description'] as String,
   
   // Sesudah (Aman terhadap null):
   description: json['description'] as String? ?? '',
   ```
2. **Regression Test:** Menambahkan unit test `ProductModelTest` dengan payload JSON yang memuat field bernilai `null` untuk memastikan tidak terjadi crash serupa di masa mendatang.
3. **Versi Baru:** Menaikkan build number ke `1.0.0+22` (`version: 1.0.0+22`) dan merilis ulang kandidat beta ke track internal.

---

## 6. 🤖 Penggunaan AI yang Bertanggung Jawab (Responsible AI in Log Analysis)

Dalam menganalisis log crash dan peringatan sistem menggunakan bantuan AI:

1. **Penyensoran Data Sensitif (Data Sanitization / Redaction):**
   - Sebelum mengirimkan stack trace ke model AI, data sensitif wajib disamarkan atau dihapus:
     - Mengganti User ID: `userId: "usr_987213"` $\rightarrow$ `userId: "<REDACTED_USER_ID>"`
     - Menghapus Authorization Header: `Bearer eyJhbGci...` $\rightarrow$ `Bearer <REDACTED_TOKEN>`
     - Menghapus Email & Nama Pengguna: `john.doe@example.com` $\rightarrow$ `<USER_EMAIL>`
     - Mengaburkan URL Endpoint Internal: `https://api.internal.corp/` $\rightarrow$ `https://api.example.com/`
2. **Verifikasi Manual terhadap Rekomendasi AI:**
   - Rekomendasi AI dianggap sebagai **hipotesis awal**, bukan keputusan final.
   - Setiap saran perbaikan wajib diverifikasi melalui:
     1. Pemeriksaan langsung ke source code project.
     2. Pengujian lokal dengan unit test dan widget test.
     3. Verifikasi pada perangkat uji fisik sebelum commit diajukan.

---

## 7. 💡 Refleksi

### 1. Bukti apa yang diperlukan sebelum memperluas distribusi beta?
> **Jawaban:**  
> Sebelum memperluas distribusi dari Internal Testing ke Closed/Open Testing atau Production, dibutuhkan bukti:
> - Metrik **Crash-Free Users** dan **Crash-Free Sessions** minimal mencapai target $\ge 99.5\%$.
> - Tidak ada isu crash fatal baru (P0/P1) yang belum teratasi pada versi kandidat.
> - Seluruh alur utama (*happy path*) telah diverifikasi lulus oleh tester pada representasi perangkat dan versi OS target.
> - Laporan umpan balik tester tidak menunjukkan keluhan performa kritis (seperti baterai boros, freeze ANR, atau layout rusak).

### 2. Bagaimana Anda memutuskan untuk menahan atau melanjutkan rilis?
> **Jawaban:**  
> - **Keputusan Menahan Rilis (Halt/Rollback):** Diambil jika ditemukan crash yang menggagalkan fungsionalitas inti, kebocoran data pribadi/kredensial, masalah integritas transaksi/data, atau jika persentase crash-free session turun di bawah ambang batas toleransi.
> - **Keputusan Melanjutkan Rilis (Proceed/Promote):** Diambil jika seluruh pre-flight checks lulus, metrik stabilitas Crashlytics terpenuhi, tidak ada regresi kritis pada log telemetri, dan perbaikan pada rilis sebelumnya terbukti efektif menyelesaikan masalah.

### 3. Data apa yang tidak perlu dikirim ke layanan monitoring?
> **Jawaban:**  
> Data yang **TIDAK BOLEH** dikirim ke Crashlytics, Analytics, maupun logging eksternal meliputi:
> - **Personally Identifiable Information (PII):** Nama lengkap, alamat email, nomor telepon, NIK, alamat rumah, atau data medis.
> - **Kredensial & Rahasia:** Password teks polos, PIN, token JWT/OAuth, API private key, dan material signing keystore.
> - **Data Transaksi Sensitif:** Nomor kartu kredit/debit, CVV, dan saldo rahasia pengguna.
> - **Payload Beban Besar (Large Payloads):** Konten dokumen lengkap, file gambar/media mentah, atau isi chat pribadi yang melanggar privasi pengguna dan membebani kuota jaringan.
