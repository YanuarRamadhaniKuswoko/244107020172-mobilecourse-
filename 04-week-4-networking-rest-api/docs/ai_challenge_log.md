# AI Challenge Log & Verification Audit - Minggu 04

**Mata Kuliah:** Pemrograman Mobile  
**Topik:** Networking & REST API (Dio, Null-Safe Serialization, Repository Pattern, Riverpod)  
**Mahasiswa:** Yanuar Ramadhani Kuswoko (NIM: 244107020176 / Kelas: TI-2D / Absen: 25)  

---

## 1. AI Prompt yang Digunakan

Sesuai instruksi jobsheet Minggu 4, prompt berikut diberikan kepada AI Coding Assistant:

```text
Buatkan repository layer Flutter untuk endpoint GET /comments?postId={id}
dari JSONPlaceholder menggunakan Dio + flutter_riverpod.
Requirements:
- Model Comment dengan fromJson aman null (postId, id, name, email, body).
- CommentRepository dengan method fetchComments(postId) + timeout 10 detik.
- AsyncNotifierProvider dengan penanganan error otomatis (AsyncError)
  dan fungsi pesan error
  ramah pengguna untuk timeout, connection error, 404, dan 500.
- Satu unit test untuk fromJson dengan field yang hilang.
Jelaskan setiap bagian kode dalam komentar.
```

---

## 2. Output Awal Kode dari AI (Generasi Awal)

Berikut adalah *raw code generation* awal yang dihasilkan oleh AI sebelum dilakukan verifikasi dan perbaikan:

```dart
// Raw output comment_service.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Comment {
  final int postId;
  final int id;
  final String name;
  final String email;
  final String body;

  Comment({
    required this.postId,
    required this.id,
    required this.name,
    required this.email,
    required this.body,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      postId: json['postId'] as int, // Rawan Null Cast Exception
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      body: json['body'] as String,
    );
  }
}

class CommentRepository {
  // Instansiasi Dio langsung di dalam class (tidak terpusat)
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://jsonplaceholder.typicode.com',
    connectTimeout: const Duration(seconds: 10),
  ));

  Future<List<Comment>> fetchComments(int postId) async {
    final res = await _dio.get('/comments?postId=$postId');
    return (res.data as List).map((e) => Comment.fromJson(e)).toList();
  }
}

final commentRepoProvider = Provider((ref) => CommentRepository());

final commentListProvider = FutureProvider.family<List<Comment>, int>((ref, postId) async {
  return ref.watch(commentRepoProvider).fetchComments(postId);
});
```

---

## 3. Audit AI Verification Checklist

Berdasarkan *AI Verification Checklist* pada jobsheet Codelab Minggu 4:

| Kriteria Audit | Status | Temuan / Catatan Evaluasi |
|---|:---:|---|
| **1. UI tidak memanggil Dio langsung** | ✅ Lolos | Arsitektur memisahkan API Client $\rightarrow$ Repository $\rightarrow$ AsyncNotifier $\rightarrow$ UI ConsumerWidget. UI hanya mengamati provider. |
| **2. Deserialisasi `fromJson` aman null** | ⚠️ Diperbaiki | *Awal:* AI menggunakan direct cast `json['id'] as int` dan `json['name'] as String`. Jika field tidak ada, aplikasi akan melempar error `type 'Null' is not a subtype of type 'String'`.<br>*Perbaikan:* Diterapkan cast defensif `(json['id'] as num?)?.toInt() ?? 0` dan `json['name'] as String? ?? ''`. |
| **3. Pemetaan semua tipe `DioExceptionType`** | ⚠️ Diperbaiki | *Awal:* AI hanya menangani general exception tanpa detail status code.<br>*Perbaikan:* Memetakan `connectionTimeout`, `sendTimeout`, `receiveTimeout`, `connectionError`, `badResponse` (401, 403, 404, 500) menjadi pesan berbahasa Indonesia yang ramah pengguna. |
| **4. `baseUrl` dan Timeout Terpusat** | ⚠️ Diperbaiki | *Awal:* AI menginstansiasi Dio baru secara lokal di dalam `CommentRepository`.<br>*Perbaikan:* Memanfaatkan `dioProvider` yang mereferensikan konfigurasi sentral `createDio()` di `api_client.dart`. |
| **5. Pengujian Unit & Edge Cases** | ⚠️ Diperbaiki | *Awal:* AI hanya menguji happy path dengan JSON lengkap.<br>*Perbaikan:* Menambahkan unit test untuk field hilang, payload JSON kosong total `{}` (`Edge Case`), serta verifikasi provider dengan `FakeCommentRepository` tanpa koneksi internet sungguhan. |
| **6. Lolos Lint & Analyzer (`flutter analyze` & `flutter test`)** | ✅ Lolos | Seluruh kode lolos analisis 0 warning/issue dan semua unit test lulus 100%. |

---

## 4. Rincian Perbaikan & Refactoring yang Dilakukan

1. **Defensive Null-Safe Deserialization:**
   ```dart
   factory Comment.fromJson(Map<String, dynamic> json) {
     return Comment(
       postId: (json['postId'] as num?)?.toInt() ?? 0,
       id: (json['id'] as num?)?.toInt() ?? 0,
       name: json['name'] as String? ?? '',
       email: json['email'] as String? ?? '',
       body: json['body'] as String? ?? '',
     );
   }
   ```
   *Alasan Teknis:* API pihak ketiga atau kondisi payload parsial tidak boleh menyebabkan *crash* pada aplikasi mobile.

2. **Sentralisasi Dependency Jaringan (Inversion of Control):**
   ```dart
   final commentRepositoryProvider = Provider<CommentRepository>(
     (ref) => CommentRepository(ref.watch(dioProvider)),
   );
   ```
   *Alasan Teknis:* Memastikan seluruh request HTTP mematuhi konfigurasi interceptor, timeout, dan headers yang seragam, serta mempermudah pengujian mocking/faking repository.

3. **Penggunaan Modern `FamilyAsyncNotifier`:**
   ```dart
   class CommentListNotifier extends FamilyAsyncNotifier<List<Comment>, int> {
     @override
     Future<List<Comment>> build(int arg) async {
       final repository = ref.watch(commentRepositoryProvider);
       return repository.fetchComments(arg);
     }
     ...
   }
   ```
   *Alasan Teknis:* Memberikan dukungan *mutations*, refresh on-demand, dan lifecycle state `AsyncLoading`/`AsyncError`/`AsyncData` secara terstruktur dengan parameter dinamis (`postId`).

---

## 5. Bukti Hasil Pengujian (Verification Results)

### Menjalankan `flutter test test/comment_test.dart`
```text
00:00 +0: Comment Model Unit Tests fromJson aman terhadap field yang hilang / null
00:00 +1: Comment Model Unit Tests fromJson aman terhadap JSON kosong total (Edge Case)
00:00 +2: Comment Model Unit Tests toJson menghasilkan Map yang sesuai
00:00 +3: Comment Provider Unit Tests commentListProvider sukses dengan FakeCommentRepository
00:00 +4: Comment Provider Unit Tests friendlyErrorMessage memetakan error komentar dengan tepat
00:00 +5: All tests passed!
```

### Menjalankan `flutter analyze`
```text
Analyzing 04-week-4-networking-rest-api...
No issues found! (ran in 1.2s)
```

---

## 6. Kesimpulan & Refleksi Teknis

Penerapan AI mempercepat konstruksi layer data. Namun, peran engineer sangat krusial dalam:
- Memastikan ketahanan terhadap *null pointer / type cast exception*.
- Mempertahankan integritas pola arsitektur (*Repository Pattern* terpusat).
- Merancang skenario pengujian unit yang mencakup *edge cases* dan isolasi mock data.
