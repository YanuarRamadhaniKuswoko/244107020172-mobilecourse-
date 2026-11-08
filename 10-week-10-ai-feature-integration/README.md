# Week 10 – Integrasi Fitur AI

> **Jobsheet:** [#10 Integrasi Fitur AI](https://jti-polinema.github.io/flutter-codelab/10-minggu-10-ai-feature-integration/)  
> **Repository:** `10-week-10-ai-feature-integration/`

---

## 👨‍💻 Identitas Mahasiswa

| Informasi | Keterangan |
|---|---|
| **Nama** | Yanuar Ramadhani Kuswoko |
| **NIM** | 244107020172 |
| **Kelas / Absen** | TI-2D / 25 |
| **Mata Kuliah** | Pemrograman Mobile |
| **Minggu** | 10 – Integrasi Fitur AI |

---

## 📌 Ringkasan Fitur yang Diintegrasikan

Pada tugas praktikum Minggu 10, diintegrasikan fitur **Chat Asisten AI Kampus** ke dalam aplikasi catatan berbasis Clean Architecture (melanjutkan project Minggu 7 dan 9):

1. **Layanan AI (`AiService`)**  
   - Mengintegrasikan Google Gemini API (`gemini-pro:generateContent`) via HTTP POST request.
   - Mengamankan kunci API menggunakan `flutter_secure_storage` sehingga token tidak pernah di-hardcode ke source code.
2. **Antarmuka Chat (`ChatScreen`)**  
   - Menampilkan percakapan riwayat tanya jawab antara pengguna dan asisten AI.
   - Dilengkapi *streaming response* (efek animasi ketik teks kata demi kata secara real-time) dan indikator loading saat menunggu respon dari cloud API.
   - Banner privasi dan dialog pengaturan kunci API (Gemini API Key).
3. **Penyaringan Data Sensitif (Privacy Filter)**  
   - Melakukan sanitasi dan validasi input regex untuk mendeteksi NIK (16 digit) dan nomor telepon Indonesia sebelum dikirim ke API publik.
4. **Desain Fallback & Error Handling**  
   - Menyediakan dialog fallback ramah pengguna (`Layanan AI Sibuk`) dengan opsi mencoba lagi atau menggunakan mode offline jika API gagal/kuota habis.

---

## 🏗️ Arsitektur Integrasi AI

Sesuai dengan Bagian 2 Jobsheet Minggu 10:

```
+---------------------------------------+       HTTPS       +-----------------------------+
|              Flutter UI               | <---------------> |      Google Gemini API      |
|  (ChatScreen, NotesPage, NoteTile)    |    (http/JSON)    |  (gemini-pro:generateContent|
+---------------------------------------+                   +-----------------------------+
        |                                                                  |
        | Kunci API (Secure Storage)                                       | Respon AI
        v                                                                  v
+---------------------------------------+                   +-----------------------------+
|        flutter_secure_storage         |                   |  Streaming / Fallback Dialog|
|     (ai_api_key disimpan aman)        |                   | (Layanan AI Sibuk / Offline)|
+---------------------------------------+                   +-----------------------------+
        |
        v
+---------------------------------------+
|        Local Database (SQLite)        |
|    (Mode Offline & Catatan Lokal)     |
+---------------------------------------+
```

---

## 🛡️ Tabel Risiko dan Mitigasi (Privasi dan Biaya)

Berdasarkan Jobsheet Bagian 4:

| Risiko | Dampak | Strategi Mitigasi yang Diterapkan |
|---|---|---|
| **Bocor data pribadi pengguna (NIK, No HP)** | Pelanggaran privasi & UU PDP | Validasi regex client-side pada `ChatScreen` sebelum request dikirim ke AI API. Input sensitif langsung ditolak dengan SnackBar peringatan. |
| **Biaya API membengkak / Kuota habis** | Pengeluaran melonjak atau rate-limit | Penerapan *System Prompt* ketat ("maksimal 2 kalimat") untuk menekan jumlah token output dan input. Kunci API dapat dikonfigurasi per pengguna. |
| **API Error / Downtime / Jaringan Terputus** | Aplikasi crash atau pengguna bingung | Mekanisme `try-catch` dengan dialog fallback ramah (`Layanan AI Sibuk - Coba lagi nanti atau gunakan mode offline`). |
| **Respons halusinasi atau tidak relevan** | Informasi akademik menyesatkan | Pembatasan persona eksplisit melalui system prompt: *"Kamu asisten kampus ramah, jawab dalam Bahasa Indonesia, maksimal 2 kalimat"*. |
| **Kunci API bocor di repository publik** | Akun disalahgunakan pihak asing | Kunci API disimpan eksklusif melalui `flutter_secure_storage` terenkripsi di keychain/keystore perangkat, bukan di file konfigurasi publik. |

---

## 🧪 Bukti Mesin Hijau (Green Verification)

Seluruh kode terverifikasi bersih dan lulus 100% dari pengujian statis serta automated unit/widget testing:

### 1. `flutter analyze`

```text
Analyzing 10-week-10-ai-feature-integration...                  
No issues found! (ran in 2.9s)
```

### 2. `flutter test`

```text
00:00 +0: D:/mobile/10-week-10-ai-feature-integration/test/ai_service_test.dart: AiService Tests Throws exception when API key is missing
00:00 +1: D:/mobile/10-week-10-ai-feature-integration/test/ai_service_test.dart: AiService Tests ask() returns AI response text on HTTP 200
00:00 +2: D:/mobile/10-week-10-ai-feature-integration/test/ai_service_test.dart: AiService Tests ask() throws exception on HTTP error (e.g. 500)
00:00 +3: D:/mobile/10-week-10-ai-feature-integration/test/ai_service_test.dart: AiService Tests saveApiKey() and getApiKey() securely store and retrieve key
00:00 +4: D:/mobile/10-week-10-ai-feature-integration/test/chat_screen_test.dart: ChatScreen Widget Tests Renders initial chat elements correctly
00:01 +16: D:/mobile/10-week-10-ai-feature-integration/test/chat_screen_test.dart: ChatScreen Widget Tests Blocks sensitive data (NIK) and shows privacy warning SnackBar
00:02 +24: D:/mobile/10-week-10-ai-feature-integration/test/chat_screen_test.dart: ChatScreen Widget Tests Sends question and streams AI response bubble
00:02 +25: D:/mobile/10-week-10-ai-feature-integration/test/chat_screen_test.dart: ChatScreen Widget Tests Displays fallback dialog when AI service throws error
00:02 +26: D:/mobile/10-week-10-ai-feature-integration/test/widget_test.dart: NotesPage renders note cards cleanly
00:02 +28: All tests passed!
```

---

## 📝 Refleksi Pembelajaran

1. **Fitur AI mana yang Anda integrasikan dan mengapa?**  
   *Jawaban:* Fitur yang diintegrasikan adalah **Chat Asisten AI Kampus** berbasis Gemini LLM. Fitur ini dipilih karena sangat relevan untuk melengkapi aplikasi catatan mahasiswa, memungkinkan mahasiswa bertanya seputar perkuliahan dan ringkasan materi secara interaktif langsung dari aplikasi mobile.

2. **Bagaimana Anda melindungi privasi pengguna saat menggunakan AI API?**  
   *Jawaban:* Privasi dilindungi dengan dua lapisan:
   - **Penyimpanan:** Kunci API disimpan dalam `flutter_secure_storage` (dienkripsi pada level OS) sehingga tidak tercantum di file kode.
   - **Validasi Input Client-Side:** Sebelum dikirim ke endpoint cloud, teks pesan diperiksa menggunakan pola Regex untuk mendeteksi NIK (16 digit) dan format nomor telepon. Jika terdeteksi, pengiriman diblokir dan pengguna diperingatkan untuk menggunakan data anonim.

3. **Fallback apa yang Anda sediakan jika layanan AI error?**  
   *Jawaban:* Ketika request ke server AI mengalami timeout, error status code (misal 429 atau 500), atau kunci belum dipasang, aplikasi menangkap exception tersebut dan menampilkan `AlertDialog` ramah bertajuk *"Layanan AI Sibuk – Coba lagi nanti atau gunakan mode offline."* dengan opsi menuju pengaturan kunci API atau menutup dialog tanpa membuat aplikasi crash.

4. **Satu hal yang Anda pelajari tentang UX fitur AI di mobile?**  
   *Jawaban:* Fitur AI di mobile sangat membutuhkan umpan balik visual yang responsif. Karena pemanggilan model AI berbasis cloud membutuhkan latensi jaringan beberapa detik, penggunaan *loading indicator* dan *streaming response* (animasi teks muncul bertahap) memberikan pengalaman pengguna (UX) yang hidup, meyakinkan pengguna bahwa sistem sedang memproses jawaban daripada mengira aplikasi macet (*freeze*).

---

## 📸 Panduan Screenshot

File screenshot pengujian pada emulator/perangkat dapat disimpan pada folder `screenshots/`:

| Nama File | Keterangan Tampilan |
|---|---|
| `screenshots/01_chat_interface.png` | Antarmuka layar chat AI dengan pesan selamat datang dan banner privasi |
| `screenshots/02_api_key_dialog.png` | Dialog pengaturan Gemini API Key dengan Secure Storage |
| `screenshots/03_streaming_response.png` | Respons jawaban asisten AI dengan streaming teks |
| `screenshots/04_privacy_warning.png` | Peringatan privasi saat input mengandung data sensitif (NIK) |
| `screenshots/05_fallback_dialog.png` | Dialog fallback *"Layanan AI Sibuk"* saat terjadi error / kuota habis |

---

## 🚀 Cara Menjalankan

```bash
# 1. Pindah ke direktori minggu 10
cd 10-week-10-ai-feature-integration

# 2. Unduh dependensi
flutter pub get

# 3. Jalankan pengujian
flutter test

# 4. Jalankan aplikasi di emulator atau desktop
flutter run
```

