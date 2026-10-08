# #06 | Authentication, Security & Firebase Cloud Messaging (FCM)

**Mata Kuliah:** Pemrograman Mobile  
**Minggu:** 06  
**Topik:** Authentication Flow, Secure Storage (Keystore/Keychain), Token Refresh Interceptor (Dio 401), Route Guard (GoRouter), FCM Permission, Token Lifecycle (getToken, onTokenRefresh), Topic Messaging, 3 App States Testing Matrix, Refactoring, & Automated Testing  

---

## Identitas Mahasiswa

| Informasi | Keterangan |
|---|---|
| **Nama** | Yanuar Ramadhani Kuswoko |
| **NIM** | 244107020176 |
| **Kelas / Absen** | TI-2D / 25 |
| **Semester** | 5 |
| **Mata Kuliah** | Pemrograman Mobile |
| **Program Studi** | D-IV Teknik Informatika |
| **Jurusan** | Teknologi Informasi |
| **Institusi** | Politeknik Negeri Malang |

---

## 🎯 Tujuan Pembelajaran

Setelah menyelesaikan seluruh modul praktikum (Praktikum 1, 2, dan 3) pada minggu ke-6 ini, mahasiswa mampu:
1. Menjelaskan alur autentikasi (*Firebase Auth*, *JWT*, *OAuth / Google Login*) dan perbedaan peran antara *ID token*, *access token*, dan *refresh token*.
2. Menyimpan token secara aman pada platform enkripsi native (*Android Keystore / iOS Keychain*) menggunakan **`flutter_secure_storage`**.
3. Menerapkan interceptor **Dio** untuk penyematan header `Authorization: Bearer <token>` otomatis dan penanganan *error 401 Unauthorized* dengan *auto-refresh single retry*.
4. Mengamankan navigasi antarmuka dengan **Authentication Route Guard** pada **GoRouter** berbasis state autentikasi reaktif **Riverpod** (`AsyncNotifier`).
5. Menjelaskan arsitektur FCM (*App Server*, *FCM Backend*, dan *Perangkat Mobile*) serta siklus hidup token (*getToken*, *onTokenRefresh*).
6. Membedakan *notification payload* vs *data payload* dan perilakunya pada tiga state aplikasi (*Foreground*, *Background*, dan *Terminated*).
7. Menangani klik notifikasi untuk navigasi rute dinamis (*deep linking* ke `/pengumuman/:id`) serta pengelompokan broadcast melalui *Topic Messaging* (`pengumuman-kampus`).
8. Menerapkan prinsip keamanan dasar aplikasi mobile sesuai pedoman *OWASP Mobile Top 10* (tidak menyimpan token di SharedPreferences, tidak mencetak token penuh di log/tampilan).

---

## 📋 Checklist Hasil Pengerjaan Praktikum (1, 2, & 3)

- [x] **Praktikum 1 — Login, Secure Storage & Token Refresh:**
  - [x] Inisialisasi project Flutter `campus_notify` dengan dependensi `flutter_riverpod`, `go_router`, `dio`, `flutter_secure_storage`, `firebase_core`, `firebase_messaging`, dan `flutter_local_notifications`.
  - [x] Membuat `TokenStore` di [lib/data/token_store.dart](lib/data/token_store.dart) sebagai pintu tunggal penyimpanan aman token ke *Android Keystore / iOS Keychain* via `FlutterSecureStorage`.
  - [x] Membuat model `AuthSession` dan `AuthRepository` di [lib/data/auth_repository.dart](lib/data/auth_repository.dart) untuk mensimulasikan login email/password serta penerbitan JWT access token dan refresh token.
  - [x] Mengonfigurasi `buildApiClient` di [lib/data/api_client.dart](lib/data/api_client.dart) dengan Dio Interceptor:
    - `onRequest`: Otomatis menyematkan header `Authorization: Bearer <access_token>`.
    - `onError (401)`: Otomatis menukar *refresh token*, menyimpan *access token* baru ke secure storage, dan melakukan retry request asli sebanyak 1 kali. Jika refresh gagal, sesi dibersihkan (*force logout*).
  - [x] Mengimplementasikan `authStateProvider` (`AsyncNotifierProvider<AuthNotifier, bool>`) di [lib/providers/auth_provider.dart](lib/providers/auth_provider.dart) untuk manajemen status sesi pengguna.
  - [x] Mengonfigurasi **Authentication Route Guard** di [lib/routes.dart](lib/routes.dart) via `GoRouter redirect`: jika belum login dialihkan ke `/login`, jika sudah login dialihkan ke `/`.
  - [x] Membangun antarmuka `LoginPage` di [lib/pages/login_page.dart](lib/pages/login_page.dart) dengan validasi form, visibilitas password, indikator loading, dan edukasi keamanan.
  - [x] Membangun antarmuka `HomePage` di [lib/pages/home_page.dart](lib/pages/home_page.dart) dengan kartu status token terpotong (*masked token*), simulasi rotasi token manual, pengujian interceptor Dio, dan navigasi pengumuman.
  - [x] Membangun antarmuka `AnnouncementPage` di [lib/pages/announcement_page.dart](lib/pages/announcement_page.dart) untuk demonstrasi tujuan deep link `/pengumuman/:id`.

- [x] **Praktikum 2 — FCM, Permission, & Token Lifecycle:**
  - [x] Konfigurasi runtime permission Android 13+ (`POST_NOTIFICATIONS`) dan metadata default channel pada [android/app/src/main/AndroidManifest.xml](android/app/src/main/AndroidManifest.xml).
  - [x] Mengimplementasikan service FCM lengkap pada [lib/messaging/push_service.dart](lib/messaging/push_service.dart):
    - `requestNotificationPermission()`: Meminta izin runtime notifikasi (alert, badge, sound).
    - `initLocalNotifications()`: Konfigurasi `FlutterLocalNotificationsPlugin` dengan channel `pengumuman_channel` (Importance High & Priority High).
    - `initFcmToken()`: Mengambil token awal via `getToken()`, mendaftarkan listener `onTokenRefresh`, dan berlangganan topik massal `pengumuman-kampus`.
    - `sendTokenToBackend()`: Menyusun payload dan mengirim token perangkat ke backend kampus (`POST /devices` dengan format `{ fcm_token, platform, updated_at }`).
    - `subscribeTopic()` & `unsubscribeTopic()`: Pengelolaan langganan siaran massal kampus.
    - `maskToken()`: Utilitas pemotongan token (12 karakter awal + penanda enkripsi) demi kepatuhan keamanan data.
  - [x] Mengelola state siklus hidup FCM reaktif pada [lib/providers/push_provider.dart](lib/providers/push_provider.dart) (`fcmProvider`).
  - [x] Membangun antarmuka **Dashboard FCM & Token Lifecycle** pada [lib/pages/home_page.dart](lib/pages/home_page.dart) yang menampilkan badge izin runtime, token terpotong, switch langganan topik `pengumuman-kampus`, tombol simulasi `onTokenRefresh`, serta live visual log `POST /devices`.

- [x] **Praktikum 3 — Payload, 3 App States, Klik Deep Link & Topic Messaging:**
  - [x] Mengimplementasikan background handler top-level dengan anotasi `@pragma('vm:entry-point')` di [lib/messaging/push_service.dart](lib/messaging/push_service.dart) (bebas dari `BuildContext` / Riverpod container).
  - [x] Menangani payload gabungan `notification + data` pada ketiga state aplikasi:
    - **Foreground State:** Memicu local banner manual via `flutter_local_notifications` pada listener `onMessage`.
    - **Background State:** Menangkap interaksi klik pengguna via `onMessageOpenedApp` dan meneruskan `data.route` ke GoRouter.
    - **Terminated State:** Mengambil initial payload via `getInitialMessage()` / `pendingDeepLink` saat aplikasi melakukan cold boot startup.
  - [x] Menambahkan antarmuka interaktif **Simulator Pengujian 3 State Aplikasi** dan **Inspektor Payload FCM HTTP v1 JSON** di [lib/pages/home_page.dart](lib/pages/home_page.dart).
  - [x] Menyusun matriks pengujian 3 app state secara lengkap di README dan dokumen audit AI.

- [x] **Refactoring & AI Prompt Challenge:**
  - [x] Sentralisasi seluruh rute dan ekstraksi fungsi murni `routeFromMessage(Map<String, dynamic> data)` di [lib/routes.dart](lib/routes.dart) agar dapat diuji unit tanpa ketergantungan Firebase SDK.
  - [x] Pemetaan respons error jaringan dan HTTP status code menjadi pesan yang ramah pengguna di [lib/data/api_errors.dart](lib/data/api_errors.dart).
  - [x] Menyusun laporan AI Prompt Challenge, verification checklist, mitigasi isu isolate background, dan justifikasi teknis di [docs/ai_challenge_log.md](docs/ai_challenge_log.md).

- [x] **Testing & Quality Assurance:**
  - [x] Unit test autentikasi di [test/auth_push_test.dart](test/auth_push_test.dart) (routing, token store, mock login, token refresh, error mapper).
  - [x] Unit test FCM & Token Lifecycle di [test/fcm_lifecycle_test.dart](test/fcm_lifecycle_test.dart) (keamanan token masking, format payload `POST /devices`, simulasi `onTokenRefresh`, topic subscription).
  - [x] Unit test Matriks 3 App State di [test/app_state_matrix_test.dart](test/app_state_matrix_test.dart) (ekstraksi rute remote data payload, normalisasi path, dan handling pending deep link startup).
  - [x] Widget test di [test/widget_test.dart](test/widget_test.dart) (rendering form login dan detail pengumuman).
  - [x] Seluruh 18 test lulus 100% (`flutter test`).
  - [x] Analisis statis bersih tanpa issue (`flutter analyze` -> *No issues found!*).

---

## 📊 Matriks Pengujian Wajib 3 State Aplikasi

Pengujian ketiga state aplikasi dilakukan dengan payload gabungan yang sama:

```json
{
  "message": {
    "topic": "pengumuman-kampus",
    "notification": {
      "title": "Jadwal kuliah berubah",
      "body": "Kelas Mobile pindah ke Ruang A2 jam 13.00"
    },
    "data": {
      "route": "/pengumuman/3",
      "id": "3"
    }
  }
}
```

| State Aplikasi | Perilaku Sistem & Handler Aktif | Skenario / Cara Uji | Hasil Tampilan & Navigasi | Status |
|---|---|---|---|:---:|
| **1. Foreground**<br>*(Aplikasi Sedang Terbuka)* | Sistem Android **tidak** menampilkan banner otomatis. Handler `FirebaseMessaging.onMessage` menangkap event lalu memicu banner lokal manual via `_localNotifications.show()`. | Aplikasi dalam keadaan terbuka di layar depan, notifikasi dikirim dari backend / console / simulator. | Muncul banner *heads-up* lokal di atas layar dengan suara/getar. Saat banner diklik, payload diteruskan dan membuka `/pengumuman/3`. | ✅ **LULUS** |
| **2. Background**<br>*(Aplikasi Diminimize / di Latar Belakang)* | Sistem operasi Android secara otomatis menampilkan banner notifikasi di notification tray. Handler `FirebaseMessaging.onMessageOpenedApp` aktif saat banner diklik. | Buka aplikasi, tekan tombol *Home*, kirim payload notifikasi, lalu klik banner dari status bar Android. | Aplikasi terbuka kembali ke depan dan langsung bernavigasi ke halaman tujuan deep link `/pengumuman/3`. | ✅ **LULUS** |
| **3. Terminated**<br>*(Aplikasi Dimatikan / Force Close)* | Sistem operasi menampilkan notifikasi di status bar. Saat diklik, OS melakukan *cold boot* aplikasi dan `FirebaseMessaging.instance.getInitialMessage()` membaca payload awal saat startup. | Lakukan *swipe-close* / matikan aplikasi secara penuh, kirim notifikasi, lalu klik banner notifikasi. | Aplikasi melakukan *launch* dari awal, inisialisasi awal membaca `getInitialMessage()`, dan router mengarahkan ke `/pengumuman/3`. | ✅ **LULUS** |

---

## 🏛️ Arsitektur Lengkap & Diagram Alur

```
+---------------------------------------------------------------------------------------------------+
|                                 ARSITEKTUR INTEGRASI AUTH & FCM                                   |
+---------------------------------------------------------------------------------------------------+

     [ Mahasiswa ] ───(Login)───> [ TokenStore ] ───(Access Token)───> [ Dio: onRequest ]
                                   (Secure Keystore)                         │
                                                                             ▼
                                                                     [ Server Kampus ]
                                                                             │ (Status 401)
                                                                             ▼
                                  [ TokenStore ] <──(Renew Token)─── [ Dio: onError ]
                                                                             │
                                                                             ▼ (Retry Request)
                                                                     [ 200 OK Berhasil ]

     [ Server Kampus ] ──(Kirim Push)──> [ Firebase Cloud Messaging (FCM) ]
                                                        │
                      ┌─────────────────────────────────┼────────────────────────────────┐
                      ▼                                 ▼                                ▼
            [ 1. State Foreground ]           [ 2. State Background ]          [ 3. State Terminated ]
                      │                                 │                                │
                      ▼                                 ▼                                ▼
            onMessage Listener               onMessageOpenedApp                getInitialMessage()
                      │                                 │                                │
                      ▼                                 │                                │
            Banner Lokal Manual                         │                                │
            (flutter_local_notifications)               │                                │
                      │ (User Click)                    │ (User Click)                   │ (User Click)
                      └─────────────────────────────────┴────────────────────────────────┘
                                                        │
                                                        ▼
                                      [ GoRouter: routeFromMessage ]
                                                        │
                                                        ▼
                                            [ /pengumuman/:id ]
```

---

## 🔒 Prinsip Keamanan Dasar Aplikasi Mobile

1. **Penyimpanan Token Hanya di Keystore / Keychain:**
   - Token tidak pernah disimpan di `SharedPreferences` (file XML plaintext). Seluruh `access_token` dan `refresh_token` disimpan menggunakan `flutter_secure_storage`.
2. **Token Masking di Seluruh Tampilan & Log:**
   - Sesuai standar keamanan, seluruh token registrasi FCM dan token autentikasi dipotong menjadi format terproteksi (`c7K8L1mN0pQ9... [TERENKRIPSI]`).
3. **Pemisahan Broadcast Topik vs Personal Token:**
   - Siaran massal menggunakan **FCM Topic Messaging** (`pengumuman-kampus`).
   - Informasi rahasia/personal (nilai, tagihan) selalu menggunakan **Device Registration Token** spesifik.

---

## 🧪 Hasil Pengujian Otomatis (`flutter test`)

Semua 18 skenario pengujian otomatis berhasil lulus 100%:

```bash
$ flutter test
00:00 +0: loading D:/mobile/06-week-6-authentication-security-fcm/test/app_state_matrix_test.dart
00:00 +1: Testing Praktikum 3: Ekstraksi route dari remote data payload gabungan
00:00 +2: Testing Praktikum 3: Ekstraksi route menormalisasi rute tanpa leading slash
00:00 +3: Testing Praktikum 3: Ekstraksi route mengembalikan default root "/" jika route kosong
00:00 +4: Testing Praktikum 3: Handling pending deep link pada startup state Terminated
00:00 +5: Testing Praktikum 1: routeFromMessage menangani route kosong dan tanpa slash
00:00 +6: Testing Praktikum 1: data payload membawa id pengumuman dan rute tujuan
00:00 +7: Testing Praktikum 1: FakeTokenStore dapat menyimpan, membaca, dan menghapus token
00:00 +8: Testing Praktikum 1: AuthRepository login berhasil dengan format email dan password valid
00:00 +9: Testing Praktikum 2: PushService.maskToken memotong token dengan aman
00:00 +10: Testing Praktikum 2: PushService.sendTokenToBackend menyusun payload POST /devices
00:00 +11: Testing Praktikum 2: FcmNotifier simulasi onTokenRefresh dan riwayat sync
00:00 +12: Testing Praktikum 2: FcmNotifier langganan topik switch
00:00 +13: Testing Widget: LoginPage renders form, branding, and input fields
00:01 +14: Testing Widget: AnnouncementPage renders correctly with parameter ID
00:01 +15: Testing Praktikum 1: AuthRepository login melempar error saat input salah
00:01 +16: Testing Praktikum 1: AuthRepository refresh token mengembalikan access token baru
00:01 +17: Testing Praktikum 1: Refresh token kosong / expired memaksa login ulang
00:01 +18: Testing Praktikum 1: ApiErrorMapper menghasilkan pesan yang ramah pengguna
00:01 +18: All tests passed!
```

Analisis statis Dart:
```bash
$ flutter analyze
Analyzing 06-week-6-authentication-security-fcm...
No issues found! (ran in 3.3s)
```

---

## 🛠️ Refactoring Challenge

Pada modul Minggu 6, telah diterapkan 3 poin refactoring utama untuk meningkatkan *clean architecture*, testabilitas, dan *developer experience*:

1. **Sentralisasi Konstanta Rute ([lib/routes.dart](lib/routes.dart)):**
   - Seluruh string path (`/login`, `/`, `/pengumuman/:id`) dipusatkan pada class `AppRoutes`.
   - Menghindari duplikasi string (*magic string*) dan menjamin konsistensi antara payload remote FCM (`data.route`) dan route handler GoRouter.

2. **Ekstraksi Fungsi Murni Parsing Rute (`routeFromMessage`):**
   - Logika ekstraksi dan normalisasi path dari payload remote FCM diekstrak ke fungsi murni `routeFromMessage(Map<String, dynamic> data)`.
   - Memungkinkan pengujian unit 100% otomatis di [test/app_state_matrix_test.dart](test/app_state_matrix_test.dart) tanpa perlu menginisialisasi atau memalsukan (*mock*) platform native Firebase.

3. **Pemisahan Pemetaan Error Jaringan ([lib/data/api_errors.dart](lib/data/api_errors.dart)):**
   - Pemetaan `DioException` (401, 403, 404, 500, timeout, connection error) dipisahkan dari layer UI ke `ApiErrorMapper`.
   - Widget UI (misalnya form login) hanya menerima teks pesan yang ramah pengguna (*user-friendly*), bukan pesan error mentah dari socket/server.

---

## ⚠️ Error Umum dan Solusinya

Berikut adalah rangkuman masalah yang sering ditemui pada integrasi Authentication, Secure Storage, dan FCM beserta solusi standar industri:

| No | Gejala Error (*Symptoms*) | Penyebab Utama | Solusi & Tindakan Pencegahan |
|:---:|---|---|---|
| **1** | **Token FCM bernilai `null` di Emulator** | Emulator Android tidak dilengkapi dengan Google Play Services (mis. AOSP standar). | Gunakan Android Virtual Device (AVD) dengan ikon **Google Play Store**, atau uji langsung pada perangkat fisik Android/iOS. |
| **2** | **Banner notifikasi tidak muncul saat aplikasi di Foreground** | Sistem Android tidak memunculkan banner notifikasi otomatis saat aplikasi aktif di depan. | Pasang listener `FirebaseMessaging.onMessage` dan picu banner lokal manual via plugin `flutter_local_notifications`. |
| **3** | **Klik notifikasi tidak navigasi saat Terminated** | `getInitialMessage()` tidak dipanggil saat aplikasi melakukan *cold boot*. | Panggil `PushService.handleTerminated()` segera setelah `GoRouter` siap, lalu arahkan rute sesuai payload `data.route`. |
| **4** | **Error 401 Unauthorized berulang meski sudah login** | Interceptor tidak mengulang request asli atau *refresh token* itu sendiri telah kedaluwarsa. | Simpan *access token* baru ke secure storage, perbarui header request, dan ulangi `dio.fetch()` 1 kali. Jika refresh token mati, panggil `TokenStore.clear()` dan alihkan ke `/login`. |
| **5** | **`MissingPluginException` pada secure storage / messaging** | Terjadi akibat *Hot Reload* setelah menambahkan plugin native baru. | Hentikan proses debug secara penuh (*Stop*), lalu jalankan ulang aplikasi menggunakan `flutter run`. |
| **6** | **Notifikasi iOS tidak pernah muncul** | APNs Auth Key / Push Notification entitlement belum dikonfigurasi. | Unggah APNs Authentication Key (.p8) ke Firebase Console dan aktifkan capability *Push Notifications* serta *Background Modes* di Xcode. |

---

## ✅ Checklist Verifikasi Mandiri

- [x] **Keamanan Token:** Token hanya disimpan di `flutter_secure_storage` (Android Keystore / iOS Keychain), tidak pernah di `SharedPreferences`, log console, maupun screenshot penuh.
- [x] **Auto-Refresh 401:** Error 401 memicu refresh token satu kali lalu mengulang request asli; kegagalan refresh memaksa pengguna login ulang (*session expired*).
- [x] **Matriks 3 App State:** Ketiga status aplikasi (*Foreground*, *Background*, *Terminated*) teruji dengan payload gabungan dan membuka rute `/pengumuman/3`.
- [x] **Topic Messaging vs Token:** Topik digunakan untuk broadcast massal (`pengumuman-kampus`), sedangkan registration token digunakan untuk pesan personal.
- [x] **Kualitas Kode:** Analisis statis `flutter analyze` 100% bersih tanpa issue dan seluruh 18 unit/widget test lulus (`flutter test`).

---

---

## 🏆 Mini Project / Industry Challenge: Campus Notification App

Aplikasi **Campus Notify** pada modul Minggu 6 ini dibangun dengan memenuhi 8 kriteria standar industri:

1. **Autentikasi & Guard Route:** Alur login (mock / Firebase Auth) terlindungi dengan GoRouter `redirect` guard; pengguna yang belum login selalu diarahkan ke `/login`.
2. **Penyimpanan Token Aman & Auto-Refresh:** Token JWT disimpan di `flutter_secure_storage` (Android Keystore / iOS Keychain). Interceptor `Dio` otomatis me-refresh token 1 kali saat server merespons 401 dan melakukan logout otomatis bila refresh token mati.
3. **Integrasi FCM & Token Lifecycle:** Menangani izin runtime, mengambil token registrasi `getToken()`, memperbarui token otomatis saat `onTokenRefresh` ke backend (`POST /devices`), dan berlangganan topik `pengumuman-kampus`.
4. **Notifikasi Gabungan & Deep Linking:** Mendukung payload gabungan `notification + data`. Klik notifikasi pada 3 state aplikasi (Foreground, Background, Terminated) otomatis membuka rute tujuan `/pengumuman/:id`.
5. **Kepatuhan Privasi Data (OWASP Mobile):** Token autentikasi dan token FCM dipotong (*masked*) pada antarmuka debug dan log produksi (`c7K8L1mN0pQ9... [TERENKRIPSI]`).
6. **Panduan Artefak Screenshot:** Panduan dan daftar kebutuhan screenshot bukti praktikum disusun pada [screenshots/README.md](screenshots/README.md).
7. **Automated Testing:** Memiliki 18 unit dan widget test otomatis yang lulus 100% tanpa ketergantungan Firebase sungguhan.
8. **Dokumentasi AI Audit:** Laporan verifikasi prompt AI dan justifikasi teknis isolate background terdokumentasi pada [docs/ai_challenge_log.md](docs/ai_challenge_log.md).

### 🚀 Cara Menjalankan Aplikasi

```bash
# 1. Masuk ke direktori project
cd 06-week-6-authentication-security-fcm

# 2. Unduh seluruh dependensi
flutter pub get

# 3. Jalankan analisis statis Dart
flutter analyze

# 4. Jalankan seluruh unit test & widget test
flutter test

# 5. Jalankan aplikasi pada emulator atau perangkat fisik
flutter run
```

---

## 💡 Refleksi & Jawaban Konseptual

1. **Mengapa refresh token tidak boleh disimpan di SharedPreferences? Apa risikonya bila bocor?**
   - *Jawaban:* `SharedPreferences` pada Android menyimpan data dalam format file XML plaintext tanpa enkripsi di `/data/data/<package_name>/shared_prefs/`. Pada perangkat yang di-*root* atau diekstrak melalui backup ADB, penyerang dapat langsung membaca refresh token. Risiko kebocoran refresh token jauh lebih fatal daripada access token karena refresh token berumur panjang (mingguan/bulanan) dan memungkinkan penyerang menerbitkan access token baru secara terus-menerus untuk membajak akun pengguna. Oleh karena itu, token wajib disimpan di **`flutter_secure_storage`** yang terenkripsi oleh *Android Keystore* atau *iOS Keychain (Secure Enclave)*.

2. **Apa yang rusak bila `onTokenRefresh` diabaikan selama satu semester perkuliahan?**
   - *Jawaban:* Token registrasi FCM perangkat dapat berubah sewaktu-waktu akibat pembaruan aplikasi, instalasi ulang (*reinstall*), pembersihan cache/data aplikasi (*clear data*), atau rotasi keamanan otomatis oleh Google Play Services. Jika listener `onTokenRefresh` diabaikan dan tidak mengirimkan token baru ke backend kampus (`POST /devices`), maka server backend akan terus mengirimkan push notification ke token lama yang sudah *invalid/stale*. Akibatnya, mahasiswa tidak akan pernah menerima notifikasi pengumuman darurat, pemindahan ruang kelas, maupun jadwal ujian selama sisa semester perkuliahan.

3. **Kapan memakai topik dan kapan memakai token perangkat? Beri contoh pesan kampus untuk masing-masing.**
   - *Jawaban:*
     - **Topik (*Topic Messaging*):** Digunakan untuk pesan massal (*broadcast*) ke kelompok/kategori pengguna tanpa perlu backend mengelola ribuan token secara individual.  
       *Contoh Pesan Kampus:* "Pengumuman Libur Nasional Semester Ganjil" atau "Info Pendaftaran Beasiswa Kampus" yang dikirimkan ke topik `pengumuman-kampus` atau `mahasiswa-ti`.
     - **Token Perangkat (*Device Token*):** Digunakan untuk pesan yang bersifat personal, rahasia, dan ditargetkan khusus ke satu mahasiswa tertentu.  
       *Contoh Pesan Kampus:* "Nilai Tugas Praktikum Pemrograman Mobile Anda Telah Diperbarui" atau "Pemberitahuan Tagihan UKT Semester 6" yang dikirim langsung ke token perangkat mahasiswa yang bersangkutan.

4. **Bagian mana dari arsitektur FCM yang tidak boleh mengakses `BuildContext`?**
   - *Jawaban:* Background Message Handler (`firebaseMessagingBackgroundHandler`) yang diberi anotasi `@pragma('vm:entry-point')`. Fungsi ini dieksekusi dalam **Dart Isolate terpisah (headless engine)** saat aplikasi berada di latar belakang atau tertutup penuh tanpa adanya *widget tree* maupun instance `MaterialApp`. Mengakses `BuildContext` di sana akan memicu runtime crash. Navigasi berbasis context hanya boleh dijalankan pada handler klik interaktif pengguna (`onMessageOpenedApp` dan `handleTerminated`) di UI Main Isolate.

5. **Bagian mana dari draf AI yang Anda tolak atau perbaiki, dan mengapa?**
   - *Jawaban:*
     1. **Penempatan background handler di dalam static method kelas:** Ditolak karena Dart AOT compiler dan native Android background service membutuhkan fungsi murni **top-level** agar tidak gagal deserialisasi entry point.
     2. **Listener `onTokenRefresh` yang hanya melakukan print log:** Ditolak karena token baru wajib dikirimkan langsung ke server backend via `POST /devices` agar backend tidak menyimpan token basi.
     3. **Mencetak token penuh di log console:** Ditolak demi kepatuhan terhadap standar keamanan *OWASP Mobile*, lalu diganti dengan utilitas `PushService.maskToken()` untuk memotong tampilan token.

---

## 📚 Referensi Pendukung

- [Slide Week 06: Authentication, Security & FCM (Polinema)](file:///d:/mobile/00-slides/Week_06_Authentication_Security_FCM.html)
- [FCM Flutter Client Official Setup & Token Guide](https://firebase.google.com/docs/cloud-messaging/flutter/client)
- [FCM Message Types: Notification vs Data Payloads](https://firebase.google.com/docs/cloud-messaging/concept-options)
- [Firebase Auth for Flutter Official Documentation](https://firebase.google.com/docs/auth/flutter/start)
- [Package flutter_secure_storage (pub.dev)](https://pub.dev/packages/flutter_secure_storage)
- [Package flutter_local_notifications (pub.dev)](https://pub.dev/packages/flutter_local_notifications)
- [GoRouter: Redirect Guards & Deep Linking](https://go_router.dev/)
- [OWASP Mobile Top 10 Security Risks](https://owasp.org/www-project-mobile-top-10/)
- [Learn Dart in Y Minutes](https://learnxinyminutes.com/dart/)

