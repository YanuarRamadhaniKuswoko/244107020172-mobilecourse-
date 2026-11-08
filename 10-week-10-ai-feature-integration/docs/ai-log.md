# AI Log – Minggu 10: Integrasi Fitur AI

> **Jobsheet:** [#10 Integrasi Fitur AI](https://jti-polinema.github.io/flutter-codelab/10-minggu-10-ai-feature-integration/)  
> **Kebijakan AI:** AI diperbolehkan membantu merancang dan mengimplementasi fitur AI, tetapi setiap baris kode dibaca, diverifikasi API, diuji dengan automated testing, dan keputusan arsitektural dapat dijelaskan tanpa bergantung pada AI.

---

## 1. Prompt Design untuk Mobile (Jobsheet Bagian 3)

Sesuai panduan *Prompt Design* pada Jobsheet Minggu 10, komponen prompt dirancang secara terstruktur agar respons AI ringkas, relevan, hemat token (biaya), dan aman:

| Komponen | Implementasi / Contoh | Tujuan |
|---|---|---|
| **System prompt** | `"Kamu asisten kampus ramah, jawab dalam Bahasa Indonesia, maksimal 2 kalimat."` | Menetapkan persona asisten, batasan panjang jawaban, dan bahasa |
| **User prompt** | `"Apa jadwal kuliah hari Senin?"` atau query pertanyaan pengguna | Input langsung dari pengguna melalui antarmuka chat |
| **Konteks** | Modul catatan dan asisten informasi perkuliahan kampus | Membuat konteks respons relevan dengan lingkungan akademik |
| **Batas & Keamanan** | Jangan mengirim data sensitif (NIK, password, nomor telepon) ke LLM API | Menjaga privasi data pengguna dan kepatuhan regulasi PDP |

---

## 2. Log Prompt, Output Mentah AI, dan Verifikasi

### Sesi Prompting 1: Perancangan Service AI dan Penyimpanan Kunci Aman

#### Prompt yang Dikirim
```
Peran: Senior Flutter Developer.
Konteks: Integrasi Gemini AI API ke aplikasi Flutter Clean Architecture (Minggu 7 & 9).
Tugas: Buat AiService dengan endpoint https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent
       Kunci API harus disimpan menggunakan flutter_secure_storage, bukan hardcoded.
Batas: Ikuti instruksi Jobsheet Langkah 2. Jangan tambahkan dependensi di luar pubspec jobsheet.
Output: Kode Dart untuk lib/ai/ai_service.dart.
```

#### Output Awal AI
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AiService {
  final _storage = const FlutterSecureStorage();
  final _apiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';

  Future<String> ask(String question) async {
    final apiKey = await _storage.read(key: 'ai_api_key');
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('API key tidak tersedia. Silakan atur di pengaturan.');
    }

    final response = await http.post(
      Uri.parse('$_apiUrl?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [{
          'parts': [{'text': question}]
        }]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'];
    } else {
      throw Exception('Gagal memanggil AI API: ${response.statusCode}');
    }
  }

  Future<void> saveApiKey(String key) async {
    await _storage.write(key: 'ai_api_key', value: key);
  }
}
```

#### Verifikasi & Keputusan Refactor
- **Status:** **TERIMA DENGAN REFACTOR UNTUK TESTABILITY**.
- **Alasan:** Kode di atas 100% sesuai dengan Jobsheet Langkah 2. Namun, untuk memungkinkan *Automated Unit Testing* tanpa koneksi internet langsung atau tanpa mengekspos API key nyata ke CI/CD, ditambahkan parameter konstruktor opsional `storage` dan `client` (`http.Client`), serta method `getApiKey()` agar antarmuka pengaturan dapat membaca status kunci yang tersimpan.

---

### Sesi Prompting 2: Perancangan Chat Screen dengan Streaming & Fallback

#### Prompt yang Dikirim
```
Peran: Senior Flutter Developer.
Konteks: Chat interface untuk mobile (lib/features/chat_screen.dart).
Tugas: Buat ChatScreen dengan streaming response, indikator loading, dialog fallback jika AI error,
       dan filter pencegahan pengiriman NIK/nomor HP ke cloud API.
Batas: Sesuai Jobsheet Langkah 3 dan Bagian Fallback Design.
```

#### Output Awal AI & Analisis
```dart
// Potongan logika fallback dari Jobsheet:
try {
  final response = await aiService.ask(question);
} catch (e) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Layanan AI Sibuk'),
      content: const Text('Coba lagi nanti atau gunakan mode offline.'),
    ),
  );
}
```

- **Verifikasi Privasi:** Ditambahkan fungsi `_containsSensitiveData(text)` untuk memvalidasi input sebelum dikirim ke API:
  - Deteksi NIK: `RegExp(r'\b\d{16}\b')`
  - Deteksi Nomor Telepon: `RegExp(r'(\+62|62|08)[0-9]{8,12}')`
  Jika terdeteksi, pengiriman dibatalkan dan pengguna diberi peringatan privasi.
- **Verifikasi UX Streaming:** Untuk mensimulasikan streaming respons LLM pada antarmuka bergerak, teks respons yang diterima di-render kata demi kata secara periodik (40ms interval) dengan auto-scroll ke dasar layar.

---

## 3. Evaluasi dan Keputusan Saran AI

| No | Komponen / Usulan | Keputusan | Catatan Evaluasi |
|---|---|---|---|
| 1 | Hardcode Gemini API Key di konstanta kode | **TOLAK KERAS** | Melanggar standar keamanan & jobsheet. Kunci wajib disimpan di `FlutterSecureStorage`. |
| 2 | Struktur `AiService` sesuai Langkah 2 | **TERIMA** | Endpoint `gemini-pro:generateContent` dengan payload `contents[].parts[].text`. |
| 3 | Tambahkan dependency injection opsional di `AiService` | **TERIMA** | Memungkinkan pengujian unit (`MockClient` & `FakeSecureStorage`) tanpa internet. |
| 4 | Fallback `AlertDialog` "Layanan AI Sibuk" | **TERIMA** | Sesuai desain fallback jobsheet saat kuota habis atau jaringan terputus. |
| 5 | Filter Regex data sensitif (NIK & No HP) | **TERIMA** | Menjawab peringatan keamanan jobsheet agar data sensitif tidak bocor ke LLM pihak ketiga. |

---

## 4. Hasil Verifikasi Mesin Hijau

Proyek berhasil lulus seluruh pengujian statis dan pengujian otomatis:

```bash
# 1. Analisis Statis (0 issue, clean code)
flutter analyze
# Output:
# Analyzing 10-week-10-ai-feature-integration...
# No issues found! (ran in 2.9s)

# 2. Automated Test Suite (28 passed)
flutter test
# Output:
# 00:02 +28: All tests passed!
```

