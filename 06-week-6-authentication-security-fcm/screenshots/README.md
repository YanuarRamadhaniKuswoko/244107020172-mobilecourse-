# 📸 Panduan Screenshot Bukti Praktikum Minggu 06

Folder ini digunakan untuk menyimpan artefak tangkapan layar (*screenshots*) pembuktian fungsionalitas **Campus Notify App** (Authentication, Security, Token Lifecycle & FCM):

---

## 📋 Daftar Bukti Screenshot yang Disiapkan

| File Screenshot | Skenario Pembuktian | Yang Wajib Ditunjukkan |
|---|---|---|
| `1-auth-login-secure.png` | **Halaman Login & Form Validation** | Tampilan form login dengan email validasi `@polinema.ac.id`, tombol login loading state, dan info banner secure storage. |
| `2-masked-token-debug.png` | **Dashboard Token & Keamanan (Home Page)** | Tampilan Access Token & Refresh Token terpotong (`mock-access-f... [TERENKRIPSI]`). **PENTING: Jangan tampilkan token penuh!** |
| `3-fcm-token-lifecycle.png` | **Siklus Hidup FCM & Log `POST /devices`** | Status izin notifikasi *Granted*, token FCM terpotong, status subscribe `pengumuman-kampus`, dan terminal log sinkronisasi backend. |
| `4-foreground-notification.png` | **Pengujian State 1: Foreground Push** | Banner *heads-up* lokal muncul melayang di atas aplikasi saat aplikasi sedang aktif dibuka. |
| `5-background-notification.png` | **Pengujian State 2: Background Notification Tray** | Banner notifikasi sistem muncul di notification tray Android saat aplikasi diminimize. |
| `6-deep-link-announcement.png` | **Tujuan Navigasi Deep Link (`/pengumuman/3`)** | Halaman detail pengumuman `#3` terbuka secara otomatis setelah pengguna mengklik notifikasi pada state Foreground, Background, maupun Terminated. |

---

> [!NOTE]
> Seluruh screenshot dapat diambil langsung saat menjalankan aplikasi pada emulator Android (dengan Google Play Services) atau perangkat fisik Android/iOS.
