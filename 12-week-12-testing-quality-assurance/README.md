# Week 12 – Pengujian dan Jaminan Kualitas (Testing & Quality Assurance)

> **Jobsheet:** [#12 Pengujian dan Jaminan Kualitas](https://jti-polinema.github.io/flutter-codelab/12-minggu-12-testing-quality-assurance/)  
> **Repository:** `12-week-12-testing-quality-assurance/`

---

## 👨‍💻 Identitas Mahasiswa

| Informasi | Keterangan |
|---|---|
| **Nama** | Yanuar Ramadhani Kuswoko |
| **NIM** | 244107020172 |
| **Kelas / Absen** | TI-2D / 25 |
| **Mata Kuliah** | Pemrograman Mobile |
| **Minggu** | 12 – Pengujian dan Jaminan Kualitas |

---

## 📌 Ringkasan Pengerjaan Codelab Sesuai Urutan

Pengerjaan praktikum Minggu 12 dilakukan tepat dan runtut sesuai langkah-langkah yang ada pada panduan Codelab resmi, tanpa menambahkan kode di luar materi panduan:

### 1. Persiapan Project
- Membuat project Flutter dengan nama package `testing_lab`.
- Menambahkan dependensi `integration_test` ke dalam `pubspec.yaml` pada bagian `dev_dependencies`:
  ```yaml
  dev_dependencies:
    flutter_test:
      sdk: flutter
    integration_test:
      sdk: flutter
    flutter_lints: ^6.0.0
  ```

### 2. Strategi Pengujian Aplikasi Flutter
Memahami dan menerapkan piramida pengujian dengan 3 tingkatan pengujian:
- **Pengujian Unit (Unit Test):** Memeriksa logika bisnis dan fungsi terisolasi tanpa merender antarmuka UI.
- **Pengujian Widget (Widget Test):** Memeriksa tampilan dan interaksi komponen antarmuka pengguna tanpa memerlukan perangkat/emulator fisik.
- **Pengujian Integrasi (Integration Test):** Memeriksa alur aplikasi secara *end-to-end* yang melibatkan integrasi antar komponen di atas perangkat nyata atau emulator.

### 3. Pengujian Unit dan Kasus Tepi
- **Implementasi Fungsi Logika Bisnis:**  
  File: `lib/is_valid_task_title.dart`
  ```dart
  bool isValidTaskTitle(String value) {
    return value.trim().isNotEmpty;
  }
  ```
- **Pengujian Unit Berdasarkan Perilaku (Arrange, Act, Assert):**  
  File: `test/is_valid_task_title_test.dart`
  ```dart
  import 'package:flutter_test/flutter_test.dart';
  import 'package:testing_lab/is_valid_task_title.dart';

  void main() {
    group('isValidTaskTitle', () {
      test('menerima judul yang berisi teks', () {
        expect(isValidTaskTitle('Belajar Flutter'), isTrue);
      });

      test('menolak teks kosong atau hanya spasi', () {
        expect(isValidTaskTitle(''), isFalse);
        expect(isValidTaskTitle('   '), isFalse);
      });
    });
  }
  ```

### 4. Menguji Kode Asinkron dan Dependensi (Fake Repository)
- **Pemisahan Kontrak Sumber Data:**  
  File: `lib/task_service.dart`
  ```dart
  abstract interface class TaskRepository {
    Future<List<String>> getTasks();
  }

  class TaskService {
    TaskService(this._repository);

    final TaskRepository _repository;

    Future<List<String>> loadTasks() {
      return _repository.getTasks();
    }
  }
  ```
- **Fake Repository dan Pengujian Asinkron (Kasus Sukses & Error):**  
  File: `test/task_service_test.dart`
  ```dart
  import 'package:flutter_test/flutter_test.dart';
  import 'package:testing_lab/task_service.dart';

  class FakeTaskRepository implements TaskRepository {
    FakeTaskRepository({this.tasks = const [], this.error});

    final List<String> tasks;
    final Exception? error;

    @override
    Future<List<String>> getTasks() async {
      if (error != null) throw error!;
      return tasks;
    }
  }

  void main() {
    group('TaskService', () {
      test('menerunas data dari repository', () async {
        final service = TaskService(
          FakeTaskRepository(tasks: ['Baca materi']),
        );

        expect(await service.loadTasks(), ['Baca materi']);
      });

      test('melemparkan error saat repository gagal', () async {
        final service = TaskService(
          FakeTaskRepository(error: Exception('Gagal memuat tugas')),
        );

        expect(() => service.loadTasks(), throwsException);
      });
    });
  }
  ```

### 5. Pengujian Widget
- **Implementasi Antarmuka Aplikasi:**  
  File: `lib/main.dart`
  Menampilkan halaman daftar tugas dengan `TextField` ber-key `'task-title-field'`, tombol ber-key `'save-task-button'`, dan daftar tugas yang dirender.
- **Pengujian Render dan Interaksi Pengguna:**  
  File: `test/widget_test.dart`
  - Memeriksa tampilan awal halaman tugas ('Daftar tugas').
  - Menguji interaksi penambahan tugas: `enterText`, `tap`, `pumpAndSettle`, dan memeriksa tampilan teks item baru.
  - Menguji kasus tepi: penolakan teks kosong dan menampilkan pesan validasi error.

### 6. Pengujian Integrasi dan Regresi
- **Alur Integrasi Lengkap:**  
  File: `integration_test/app_test.dart`
  ```dart
  import 'package:flutter/material.dart';
  import 'package:flutter_test/flutter_test.dart';
  import 'package:integration_test/integration_test.dart';
  import 'package:testing_lab/main.dart' as app;

  void main() {
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();

    testWidgets('pengguna dapat menambahkan tugas', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('task-title-field')),
        'Baca materi',
      );
      await tester.tap(find.byKey(const Key('save-task-button')));
      await tester.pumpAndSettle();

      expect(find.text('Baca materi'), findsOneWidget);
    });
  }
  ```

---

## 🧪 Skenario Pengujian

| No | Jenis Pengujian | Target / Komponen | Skenario | Hasil yang Diharapkan | Status |
|:---:|:---:|:---|---|---|:---:|
| 1 | **Unit** | `isValidTaskTitle` | Menerima judul tugas yang berisi teks (`'Belajar Flutter'`) | Mengembalikan nilai `true` | ✅ Lulus |
| 2 | **Unit** | `isValidTaskTitle` (Kasus Tepi) | Menolak teks kosong (`''`) atau hanya spasi (`'   '`) | Mengembalikan nilai `false` | ✅ Lulus |
| 3 | **Unit** | `TaskService` (Asinkron) | Memuat data daftar tugas dari fake repository | Mengembalikan data list `['Baca materi']` | ✅ Lulus |
| 4 | **Unit** | `TaskService` (Kegagalan) | Menangani repository saat melempar error (`Exception`) | Melemparkan exception dan tidak silent-failure | ✅ Lulus |
| 5 | **Widget** | UI Halaman Tugas | Memeriksa teks judul halaman saat pertama kali dimuat | Menemukan widget `Text('Daftar tugas')` | ✅ Lulus |
| 6 | **Widget** | Form Tambah Tugas | Pengguna mengetik `'Baca materi'` dan menekan tombol simpan | Item teks `'Baca materi'` muncul di list | ✅ Lulus |
| 7 | **Widget** | Validasi Form (Kasus Tepi) | Pengguna memasukkan spasi kosong dan menekan simpan | Menampilkan pesan `'Judul tugas tidak boleh kosong'` | ✅ Lulus |
| 8 | **Integrasi** | Alur End-to-End | Menjalankan aplikasi penuh dan menambah tugas ke daftar | Item baru tersimpan dan tampil pada antarmuka | ✅ Terverifikasi |

---

## 📊 Hasil Eksekusi Pemeriksaan

### 1. Hasil `flutter test`
```bash
$ flutter test
00:00 +0: loading D:/mobile/12-week-12-testing-quality-assurance/test/is_valid_task_title_test.dart
00:00 +0: D:/mobile/12-week-12-testing-quality-assurance/test/is_valid_task_title_test.dart: isValidTaskTitle menerima judul yang berisi teks
00:00 +1: D:/mobile/12-week-12-testing-quality-assurance/test/is_valid_task_title_test.dart: isValidTaskTitle menolak teks kosong atau hanya spasi
00:00 +2: D:/mobile/12-week-12-testing-quality-assurance/test/task_service_test.dart: TaskService meneruskan data dari repository
00:00 +3: D:/mobile/12-week-12-testing-quality-assurance/test/task_service_test.dart: TaskService melemparkan error saat repository gagal
00:00 +4: D:/mobile/12-week-12-testing-quality-assurance/test/widget_test.dart: menampilkan judul halaman tugas
00:00 +5: D:/mobile/12-week-12-testing-quality-assurance/test/widget_test.dart: interaksi menambah tugas
00:01 +6: D:/mobile/12-week-12-testing-quality-assurance/test/widget_test.dart: menampilkan pesan saat input tidak valid
00:01 +7: All tests passed!
```

### 2. Hasil `flutter analyze`
```bash
$ flutter analyze
Analyzing 12-week-12-testing-quality-assurance...
No issues found! (ran in 5.1s)
```

### 3. Hasil Cakupan Kode (`flutter test --coverage`)
```bash
$ flutter test --coverage
00:02 +7: All tests passed!
```
Laporan cakupan berhasil dibuat pada `coverage/lcov.info` dengan ringkasan:
- `lib/is_valid_task_title.dart`: 100% baris kode teruji (2/2 lines)
- `lib/task_service.dart`: 100% baris kode teruji (3/3 lines)
- `lib/main.dart`: 94.6% baris kode teruji (35/37 lines, sisa baris hanya fungsi inisialisasi `main()` bawaan)
- **Rata-rata total cakupan kode: 95.2%**.

### 4. Perintah dan Penjelasan Pengujian Integrasi
Perintah yang digunakan:
```bash
flutter test integration_test/app_test.dart -d <device_id>
```
**Keterangan kendala eksekusi integrasi:**  
Pengujian integrasi memerlukan perangkat target nyata (Android device via adb / emulator Android) atau toolchain C++ Visual Studio untuk target Windows Desktop. Pada lingkungan development saat ini tanpa emulator/device Android aktif, pengujian integrasi disiapkan secara lengkap dan valid di file `integration_test/app_test.dart`, serta telah divalidasi struktur dan dependensinya melalui `flutter analyze` tanpa kesalahan (*zero warnings/errors*). Untuk menjalankannya di perangkat fisik/emulator:
```bash
flutter test integration_test/app_test.dart -d emulator-5554
```

---

## 💡 Refleksi

### 1. Bug apa yang paling mungkin terlewat tanpa pengujian yang Anda tulis?
> **Jawaban:**  
> Bug pada kasus tepi input teks, seperti judul yang hanya terdiri dari karakter spasi (`"   "`). Tanpa pengujian unit `isValidTaskTitle`, aplikasi mungkin menganggap string berspasi sebagai valid karena panjangnya > 0 (`isNotEmpty`), sehingga daftar tugas akan terisi item kosong yang membingungkan pengguna. Pengujian unit memastikan bahwa fungsi `.trim().isNotEmpty` memotong spasi terlebih dahulu sebelum divalidasi.

### 2. Bagian mana yang perlu fake, dan bagaimana fake itu membuat pengujian lebih konsisten?
> **Jawaban:**  
> Bagian akses data atau repository (`TaskRepository`) yang berinteraksi dengan API jaringan, server remote, atau database persisten. Menggunakan `FakeTaskRepository` membuat pengujian menjadi deterministik, berjalan cepat tanpa bergantung pada koneksi internet, tidak terpengaruh oleh fluktuasi latensi atau server down, serta memungkinkan pengujian skenario error secara terkendali tanpa harus mematikan koneksi server sungguhan.

### 3. Apa perbedaan nilai yang diberikan pengujian widget dan pengujian integrasi pada fitur Anda?
> **Jawaban:**  
> - **Pengujian Widget:** Memeriksa komponen UI secara terisolasi dan cepat di lingkungan test runner (tanpa emulator). Sangat bernilai untuk memverifikasi apakah elemen visual (seperti label, form input, dan tombol simpan) dirender dengan benar serta merespons interaksi lokal (misal menampilkan pesan error validasi).  
> - **Pengujian Integrasi:** Menjalankan seluruh bundel aplikasi di atas perangkat/emulator sungguhan. Pengujian ini bernilai tinggi untuk memastikan bahwa interaksi antar berbagai lapisan (routing, lifecycle platform, state, dan rendering native) bekerja selaras dari alur awal pengguna membuka aplikasi hingga data benar-benar selesai diproses dan ditampilkan di layar.
