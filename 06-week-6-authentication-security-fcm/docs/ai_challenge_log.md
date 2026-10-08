# 🤖 AI Challenge Log & Verification Audit - Minggu 06

**Mata Kuliah:** Pemrograman Mobile  
**Minggu:** 06  
**Topik:** Authentication, Security, Token Lifecycle & Firebase Cloud Messaging (FCM)  
**Mahasiswa:** Yanuar Ramadhani Kuswoko  
**NIM:** 244107020176  
**Kelas / Absen:** TI-2D / 25  
**Program Studi:** D-IV Teknik Informatika  
**Jurusan:** Teknologi Informasi  
**Institusi:** Politeknik Negeri Malang  

---

## 📝 1. AI Prompt Challenge yang Digunakan

Berikut adalah prompt tantangan yang diberikan kepada AI Coding Assistant:

```text
Aplikasi Flutter Campus Notification App.
Stack: firebase_messaging, flutter_local_notifications, flutter_secure_storage, go_router, Riverpod.
Buatkan PushService dengan:
- requestPermission + getToken + onTokenRefresh (kirim ke POST /devices)
- onMessage (tampilkan local notification manual)
- onMessageOpenedApp + getInitialMessage (navigasi ke data.route)
- subscribe/unsubscribe topic pengumuman-kampus
- background handler top-level dengan @pragma('vm:entry-point')
Tandai bagian yang BERBEDA untuk Android 13+ vs iOS, dan bagian yang tidak boleh mengakses BuildContext.
```

---

## 💻 2. Output Awal Kode dari AI (Generasi Awal / Raw Draft)

Berikut adalah draf awal yang dihasilkan oleh AI sebelum dilakukan audit dan perbaikan manual:

```dart
// push_service_raw.dart (Draf Awal yang Dihasilkan AI)
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class PushService {
  final _firebase = FirebaseMessaging.instance;
  final _local = FlutterLocalNotificationsPlugin();

  // ⚠️ TEMUAN 1: AI menempatkan background handler sebagai method statis di dalam class
  @pragma('vm:entry-point')
  static Future<void> handleBackground(RemoteMessage message) async {
    print("Background message: ${message.messageId}");
  }

  Future<void> init(BuildContext context) async {
    // ⚠️ TEMUAN 2: AI meminta BuildContext pada proses inisialisasi awal
    await _firebase.requestPermission();
    
    // ⚠️ TEMUAN 3: AI mencetak token secara penuh di console log
    String? token = await _firebase.getToken();
    print("FCM Token: $token");

    // ⚠️ TEMUAN 4: onTokenRefresh hanya di-print, tidak dikirim ke API backend
    _firebase.onTokenRefresh.listen((newToken) {
      print("Token refreshed: $newToken");
    });

    _firebase.subscribeToTopic('pengumuman-kampus');

    FirebaseMessaging.onBackgroundMessage(handleBackground);

    FirebaseMessaging.onMessage.listen((message) {
      // Menampilkan local notification
      _local.show(
        message.hashCode,
        message.notification?.title,
        message.notification?.body,
        const NotificationDetails(
          android: AndroidNotificationDetails('channel_id', 'Channel Name'),
        ),
      );
    });

    // ⚠️ TEMUAN 5: Navigasi menggunakan Navigator langsung bergantung pada BuildContext
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      Navigator.pushNamed(context, message.data['route']);
    });
  }
}
```

---

## 🔍 3. Audit AI Verification Checklist

Berdasarkan pedoman codelab Minggu 6, berikut adalah evaluasi dan audit kritis terhadap draf awal AI:

| No | Kriteria Verifikasi | Status Audit | Catatan Temuan & Tindakan Koreksi |
|:---:|---|:---:|---|
| **1** | **Background Handler Top-Level dengan `@pragma('vm:entry-point')`** | ❌ **Ditolak & Diperbaiki** | **Temuan:** AI membungkus handler di dalam static method class `PushService.handleBackground`.<br>**Koreksi:** Handler diekstrak menjadi **fungsi murni top-level** di luar kelas agar entry point dapat ditemukan oleh Flutter engine saat native background isolate dijalankan. |
| **2** | **`onTokenRefresh` Mengirim Token ke Backend (Bukan Sekadar Log)** | ❌ **Ditolak & Diperbaiki** | **Temuan:** AI hanya mencetak `print("Token refreshed: $newToken")`.<br>**Koreksi:** Mengintegrasikan pemanggilan `PushService.sendTokenToBackend()` via Dio (`POST /devices`) dengan payload `{ fcm_token, platform, updated_at }` agar token di database kampus selalu terbarukan. |
| **3** | **Foreground Memakai Local Notification Manual** | ✅ **Lulus (Ditingkatkan)** | **Temuan:** AI menggunakan `_local.show()`.<br>**Koreksi:** Ditingkatkan dengan konfigurasi channel berspesifikasi tinggi (`importance: Importance.high`, `priority: Priority.high`, `pengumuman_channel`) dan payload route agar banner heads-up muncul di Android. |
| **4** | **Tiga State Aplikasi (Foreground, Background, Terminated) Bernavigasi Benar** | ⚠️ **Diperbaiki** | **Temuan:** AI menggunakan `Navigator.pushNamed(context, ...)` yang bergantung pada `BuildContext` global.<br>**Koreksi:** Menggunakan `GoRouter` dengan abstraksi `pendingDeepLink` dan fungsi murni `routeFromMessage(data)` yang aman dijalankan dari startup *cold boot* (`getInitialMessage()`). |
| **5** | **Token & Secret Tidak Pernah Di-Hardcode & Tidak Dicetak Penuh** | ❌ **Ditolak & Diperbaiki** | **Temuan:** AI mencetak token penuh `print("FCM Token: $token")` yang melanggar prinsip privasi perangkat.<br>**Koreksi:** Menghapus seluruh log plaintext dan menerapkan utilitas `PushService.maskToken()` (`c7K8L1mN0pQ9... [TERENKRIPSI]`). |
| **6** | **Penyimpanan Token Hanya di `FlutterSecureStorage`** | ✅ **Lulus (Valid)** | **Temuan:** Memastikan token JWT access dan refresh tidak pernah menggunakan `SharedPreferences` yang rentan diekstrak dalam bentuk plaintext XML. |

---

## 🛠️ 4. Perbandingan Kode: Draf AI vs Kode Terverifikasi

### A. Background Message Handler

#### ❌ Draf Awal AI (Bermasalah pada AOT Isolate):
```dart
class PushService {
  @pragma('vm:entry-point')
  static Future<void> handleBackground(RemoteMessage message) async {
    print("Background message: ${message.messageId}");
  }
}
```

#### ✅ Kode Final Mahasiswa (Top-Level & Resisten Crash):
```dart
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
  } catch (_) {}

  debugPrint('[FCM Background] Diterima di isolate terpisah: ${message.messageId}');
}
```
*Justifikasi:* Anotasi `@pragma('vm:entry-point')` memberi instruksi kepada compiler Dart AOT agar fungsi tidak dihapus (*tree-shaken*) saat rilis. Menjadikannya fungsi top-level menjamin native background service Android dapat memanggil symbol entry point secara langsung tanpa memerlukan instansiasi kelas.

---

### B. Siklus Hidup Token `onTokenRefresh`

#### ❌ Draf Awal AI (Token Stale & Pasif):
```dart
_firebase.onTokenRefresh.listen((newToken) {
  print("Token refreshed: $newToken"); // Token baru tidak sampai ke server kampus!
});
```

#### ✅ Kode Final Mahasiswa (Sinkronisasi Otomatis ke Backend):
```dart
FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
  if (newToken.isNotEmpty) {
    await PushService.sendTokenToBackend(
      dio: dio,
      token: newToken,
    );
  }
});
```
*Justifikasi:* Mengabaikan `onTokenRefresh` akan menyebabkan backend mengirimkan push notification ke token lama yang sudah basi (misal setelah pengguna reinstall atau clear cache), sehingga notifikasi penting kampus tidak akan pernah sampai ke mahasiswa.

---

## 📱 5. Perbedaan Kritis Android 13+ vs iOS

| Aspek | Android 13+ (API 33+) | iOS (Apple APNs) |
|---|---|---|
| **Izin Runtime** | Wajib mendeklarasikan `<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>` di `AndroidManifest.xml` dan memanggil `FirebaseMessaging.instance.requestPermission()`. | Wajib meminta otorisasi APNs (`alert`, `badge`, `sound`) serta konfigurasi APNs Key di Apple Developer Console. |
| **Foreground Display** | Sistem Android **TIDAK** memunculkan banner saat aplikasi di foreground. Wajib memicu `_localNotifications.show()` secara manual pada listener `onMessage`. | Dapat mengonfigurasi `DarwinNotificationDetails` atau presentation options otomatis langsung dari APNs payload. |
| **Notification Channel** | Wajib membuat `AndroidNotificationChannel` dengan level *Importance High* agar banner heads-up muncul melayang di atas aplikasi. | Tidak mengenal notification channel; prioritas diatur di level payload APNs. |

---

## 🚫 6. Analisis Bagian yang Bebas dari `BuildContext`

```dart
// ❌ CONTOH SALAH (MENGAKSES CONTEXT DI BACKGROUND HANDLER):
@pragma('vm:entry-point')
Future<void> backgroundHandler(RemoteMessage message) async {
  Navigator.of(context).pushNamed('/pengumuman'); // CRASH! Tidak ada context di background
}
```

### Mengapa Dilarang?
1. **Eksekusi di Dart Isolate Terpisah:** Saat notifikasi masuk saat aplikasi ditutup/minimized, sistem operasi menjalankan *headless engine isolate*.
2. **Tidak Ada Widget Tree:** Di dalam background isolate, tidak ada `MaterialApp`, tidak ada `Element Tree`, dan tidak ada `NavigatorState`.
3. **Solusi Arsitektural:** Seluruh aksi navigasi hanya dijalankan pada handler klik interaktif pengguna (`onMessageOpenedApp` dan `handleTerminated`) yang berjalan pada UI Main Isolate.

---

## 📊 7. Matriks Pengujian 3 State Aplikasi

| State Aplikasi | Perilaku Sistem & Handler FCM | Tindakan Pengguna | Hasil Navigasi yang Diharapkan | Status Uji |
|---|---|---|---|:---:|
| **Foreground** (Aplikasi Terbuka) | Sistem tidak memunculkan banner otomatis. Handler `FirebaseMessaging.onMessage` memicu `_localNotifications.show()`. | Pengguna mengklik banner lokal yang muncul di atas layar. | Aplikasi membuka halaman detail rute `/pengumuman/3`. | ✅ **Lulus** |
| **Background** (Aplikasi Diminimize) | OS Android menampilkan banner notifikasi otomatis di notification tray. Handler `onMessageOpenedApp` menangkap payload saat banner diklik. | Pengguna mengklik banner notifikasi dari tray sistem. | Aplikasi aktif kembali dan langsung bernavigasi ke `/pengumuman/3`. | ✅ **Lulus** |
| **Terminated** (Aplikasi Mati Penuh) | OS Android menampilkan banner sistem. Saat diklik, aplikasi melakukan *cold boot* dan `getInitialMessage()` membaca payload awal. | Pengguna mengklik banner saat aplikasi dalam keadaan mati. | Aplikasi terbuka, inisialisasi awal membaca `getInitialMessage()`, dan router mengarahkan ke `/pengumuman/3`. | ✅ **Lulus** |

---

## 🏆 8. Kesimpulan & Keputusan Teknis Final

1. **Keamanan Kredensial:** Seluruh token (`access_token`, `refresh_token`, dan `fcm_token`) dikelola secara aman menggunakan `flutter_secure_storage` (Hardware Keystore/Keychain) dan utilitas masking.
2. **Resistensi Terhadap Token Stale:** Implementasi aktif listener `onTokenRefresh` menjamin token baru selalu tersinkronisasi ke endpoint backend kampus `POST /devices`.
3. **Modularitas & Testabilitas:** Pemisahan parsing rute ke fungsi murni `routeFromMessage()` di [lib/routes.dart](../lib/routes.dart) memungkinkan pengujian unit otomatis secara 100% independen tanpa mock Firebase yang kompleks.
