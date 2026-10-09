# #07 | Clean Architecture & Feature-First Refactoring

**Mata Kuliah:** Pemrograman Mobile  
**Minggu:** 07  
**Topik:** Clean Architecture, SOLID Principles, Feature-First Structure, Dependency Rule, Domain/Data/Presentation Layers, Pure Entities, Repository Pattern with Dart Records, Use Cases, Riverpod Dependency Injection, Sterility Verification, and Automated Testing  

---

## 👨‍💻 Identitas Mahasiswa

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

Setelah menyelesaikan modul Praktikum 1, 2, dan 3 pada Minggu ke-7 ini, mahasiswa mampu:
1. Menjelaskan prinsip **SOLID** dan *separation of concerns* melalui implementasi kode nyata pada Flutter.
2. Membedakan struktur **feature-first** vs **layer-first** beserta *trade-off* pemeliharaan kodenya.
3. Menguasai tiga layer utama (**Presentation**, **Domain**, dan **Data**) serta menegakkan aturan dependensi (*Dependency Rule: panah dependensi hanya mengarah ke dalam*).
4. Membedakan secara tegas antara **Entity** (objek bisnis murni) vs **Model** (representasi eksternal data dengan *serialization*).
5. Menerapkan peran **Repository Interface**, **Repository Implementation**, **Use Case**, dan **Dependency Injection (DI)** menggunakan Riverpod tanpa ketergantungan library *service locator* pihak ketiga.
6. Merefaktor proyek Minggu 5 (`week5_offline_notes`) menjadi arsitektur bersih (*Clean Architecture*) terstruktur *feature-first*.
7. Menguji Use Case murni menggunakan *Fake / In-Memory Repository* tanpa menyentuh database SQLite atau jaringan sungguhan.
8. Membuktikan sterilitas layer melalui *automated grep checks*, analisis statis (`flutter analyze`), dan pengujian unit/widget komprehensif (`flutter test`).

---

## 📋 Checklist Hasil Pengerjaan Praktikum (1, 2, & 3)

- [x] **Praktikum 1 — Audit Layer Project Lama:**
  - [x] Pemetaan seluruh file project lama (Minggu 5) ke layer arsitektur beserta analisis masalahnya.
  - [x] Audit dan penandaan tiga pelanggaran klasik:
    - Widget yang menyentuh SQLite/Dio langsung.
    - Logika bisnis (formatting tanggal, manipulasi JSON) di dalam method `build()`.
    - Instansiasi manual (kebocoran *Dependency Injection*).
  - [x] Perancangan dan pembuatan struktur target *feature-first* di `lib/features/notes/` dan `lib/core/`.
- [x] **Praktikum 2 — Domain dan Data per Fitur:**
  - [x] Membuat entitas murni `Note` di [lib/features/notes/domain/entities/note.dart](lib/features/notes/domain/entities/note.dart) (steril tanpa dependensi Flutter, tanpa `toMap`/`fromMap`).
  - [x] Membuat hirarki domain error `Failure` (`LocalFailure`, `NetworkFailure`, `ValidationFailure`) di [lib/core/failures.dart](lib/core/failures.dart).
  - [x] Mendefinisikan kontrak interface `NoteRepository` dengan Dart Records ganda `({T? data, Failure? failure})` di [lib/features/notes/domain/repositories/note_repository.dart](lib/features/notes/domain/repositories/note_repository.dart).
  - [x] Membuat *data model* `NoteModel` dengan serialisasi `toMap()`, `fromMap()`, dan konversi `.toEntity()` di [lib/features/notes/data/models/note_model.dart](lib/features/notes/data/models/note_model.dart).
  - [x] Mengisolasi koneksi database SQLite di [lib/features/notes/data/datasources/notes_database.dart](lib/features/notes/data/datasources/notes_database.dart).
  - [x] Mengimplementasikan `NoteRepositoryImpl` di [lib/features/notes/data/repositories/note_repository_impl.dart](lib/features/notes/data/repositories/note_repository_impl.dart) dengan injeksi `openDb` dan penanganan error tertutup (tidak membocorkan exception mentah).
  - [x] Membuat *Use Cases* spesifik: `GetNotes`, `AddNote`, `UpdateNote`, `DeleteNote`, dan `SyncNotes` di `lib/features/notes/domain/usecases/`.
  - [x] Ekstraksi fungsi pemformatan murni ke [lib/core/format.dart](lib/core/format.dart).
- [x] **Praktikum 3 — Presentation, DI, dan Verifikasi:**
  - [x] Mengonfigurasi wiring *Dependency Injection* terpusat via Riverpod di [lib/features/notes/presentation/providers/notes_providers.dart](lib/features/notes/presentation/providers/notes_providers.dart).
  - [x] Membangun antarmuka halaman `NotesPage` di [lib/features/notes/presentation/pages/notes_page.dart](lib/features/notes/presentation/pages/notes_page.dart) yang reaktif dan steril dari SQL/Dio.
  - [x] Membangun antarmuka form detail `NoteDetailPage` di [lib/features/notes/presentation/pages/note_detail_page.dart](lib/features/notes/presentation/pages/note_detail_page.dart).
  - [x] Membangun widget komponen `NoteTile` di [lib/features/notes/presentation/widgets/note_tile.dart](lib/features/notes/presentation/widgets/note_tile.dart).
  - [x] Menjalankan 3 verifikasi sterilitas (Presentation steril, Domain steril, Analisis statis bersih).
  - [x] Pengujian otomatis use case dengan `FakeNoteRepository` di [test/get_notes_test.dart](test/get_notes_test.dart).
  - [x] Pengujian komprehensif pada [test/usecases_test.dart](test/usecases_test.dart), [test/note_model_test.dart](test/note_model_test.dart), [test/format_test.dart](test/format_test.dart), [test/providers_test.dart](test/providers_test.dart), dan [test/widget_test.dart](test/widget_test.dart). Seluruh 20 automated tests lulus 100%.
- [x] **Dokumentasi AI Challenge & Refleksi:**
  - [x] Menyusun log tantangan prompt AI dan checklist verifikasi arsitektur di [docs/ai_challenge_log.md](docs/ai_challenge_log.md).
  - [x] Menjawab seluruh pertanyaan refleksi teknis di README.

---

## 🏛️ Praktikum 1: Audit Layer Project Lama

### 1. Pemetaan File ke Layer (Audit Project Minggu 5)

Berikut adalah tabel audit pemetaan file sebelum dilakukan refaktorisasi Clean Architecture:

| File Asal (Minggu 5) | Layer Lama | Masalah Arsitektur & Pelanggaran SOLID | Aksi Refaktorisasi |
|---|---|---|---|
| `lib/data/local/note.dart` | Data / Model | Tanggung jawab ganda (*violates SRP*): Kelas `Note` berfungsi sebagai objek entitas sekaligus serialisasi SQLite (`toMap`, `fromMap`). | **Dipecah:** Menjadi Entity murni `Note` di domain dan `NoteModel` di data. |
| `lib/data/repositories/note_repository.dart` | Data | Kontrak (*interface*) dan implementasi konkrit tercampur menjadi satu kelas. Membocorkan instance database langsung (*violates DIP*). | **Dipecah:** Menjadi kontrak interface `NoteRepository` di domain dan `NoteRepositoryImpl` di data. |
| `lib/data/local/db.dart` | Data | Fungsi pembuka database `openNotesDb()` diakses langsung tanpa abstraksi datasource. | **Dipindahkan:** Menjadi `lib/features/notes/data/datasources/notes_database.dart`. |
| `lib/data/providers.dart` | Global / Data-Presentation | File raksasa (*god file*) yang mencampurkan provider preferensi, state SQLite, sinkronisasi jaringan, dan instansiasi konkrit `NoteRepository()`. | **Dipindahkan & Diisolasi:** Disederhanakan menjadi provider per fitur di `presentation/providers/notes_providers.dart`. |
| `lib/widgets/note_tile.dart` | Presentation | Memuat logika pemformatan tanggal dan string di dalam widget (`_formatDateTime`), melanggar pemisahan logika tampilan (*violates SoC*). | **Dibersihkan:** Logika format diekstrak ke fungsi murni `lib/core/format.dart`. |
| `lib/pages/notes_page.dart` | Presentation | Memanggil metode repository konkrit dan membaca status data tanpa batas domain yang jelas. | **Dibersihkan:** Hanya mengonsumsi state Riverpod `notesProvider` dan `dirtyCountProvider`. |

### 2. Audit Tiga Pelanggaran Klasik

Sebelum refaktorisasi, dilakukan penelusuran terhadap tiga antipattern klasik:
1. **Widget menyentuh jaringan atau database langsung:**
   - *Gejala:* Adanya impor atau pemanggilan `openDatabase`, `Dio(`, `FlutterSecureStorage`, atau `SharedPreferences` di dalam widget.
2. **Logika bisnis di dalam method `build()`:**
   - *Gejala:* Adanya manipulasi tanggal (`DateFormat`), konversi JSON (`jsonDecode`), atau pemformatan ISO langsung di folder tampilan.
3. **Instansiasi manual (*DI bocor*):**
   - *Gejala:* Widget atau Notifier menuliskan `final repo = NoteRepository();` secara manual alih-alih menerima dependensi via injection.

> **Target:** Ketiga pencarian di atas **Wajib 0 hasil** di folder presentation dan domain setelah seluruh praktikum selesai.

### 3. Struktur Target (Feature-First Clean Architecture)

```
lib/
├── core/
│   ├── failures.dart                        # Hirarki domain error (murni Dart)
│   └── format.dart                          # Helper fungsi pemformatan murni (murni Dart)
├── features/
│   └── notes/
│       ├── domain/
│       │   ├── entities/
│       │   │   └── note.dart                # Pure Business Entity (tanpa Flutter & mapping)
│       │   ├── repositories/
│       │   │   └── note_repository.dart     # Interface / kontrak repository murni
│       │   └── usecases/
│       │       ├── get_notes.dart           # Use case membaca catatan
│       │       ├── add_note.dart            # Use case menambah catatan (validasi judul)
│       │       ├── update_note.dart         # Use case mengubah catatan
│       │       ├── delete_note.dart         # Use case menghapus catatan
│       │       └── sync_notes.dart          # Use case orkestrasi sinkronisasi offline
│       ├── data/
│       │   ├── datasources/
│       │   │   └── notes_database.dart      # Koneksi SQLite lokal (sqflite / FFI)
│       │   ├── models/
│       │   │   └── note_model.dart          # Model serialisasi toMap, fromMap, toEntity
│       │   └── repositories/
│       │       └── note_repository_impl.dart# Implementasi repository (SQLite + Dio sync)
│       └── presentation/
│           ├── providers/
│           │   └── notes_providers.dart     # Dependency Injection & Riverpod Notifier
│           ├── pages/
│           │   ├── notes_page.dart          # Halaman daftar catatan utama
│           │   └── note_detail_page.dart    # Halaman form pembuatan & pengeditan
│           └── widgets/
│               └── note_tile.dart           # Kartu catatan individual
├── routes.dart                              # Konfigurasi GoRouter modular
└── main.dart                                # Entry point aplikasi & ProviderScope
```

---

## ⚙️ Praktikum 2: Domain dan Data per Fitur

### 1. Entity Murni (`lib/features/notes/domain/entities/note.dart`)

Entity merepresentasikan objek bisnis murni. Entity tidak memiliki dependensi terhadap framework Flutter maupun mekanisme serialisasi database/jaringan:

```dart
class Note {
  const Note({
    this.id,
    required this.title,
    this.body = '',
    required this.updatedAt,
    this.dirty = false,
  });

  final int? id;
  final String title;
  final String body;
  final DateTime updatedAt;
  final bool dirty;

  Note copyWith({ ... }) { ... }
}
```

### 2. Failure Hierarchy & Repository Interface

Domain mendefinisikan tipe kegagalan terstruktur menggunakan *sealed class* Dart di [lib/core/failures.dart](lib/core/failures.dart):

```dart
sealed class Failure {
  const Failure(this.message);
  final String message;
}

class LocalFailure extends Failure {
  const LocalFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
```

Kontrak repository di [lib/features/notes/domain/repositories/note_repository.dart](lib/features/notes/domain/repositories/note_repository.dart) memanfaatkan fitur **Dart Records** untuk mengembalikan pasangan sukses/gagal secara eksplisit tanpa melempar exception yang tidak terduga ke presentation:

```dart
abstract class NoteRepository {
  Future<({List<Note> notes, Failure? failure})> fetchNotes();
  Future<({Note? note, Failure? failure})> getNoteById(int id);
  Future<({Note? note, Failure? failure})> addNote({required String title, String body});
  Future<({Note? note, Failure? failure})> updateNote(Note note);
  Future<({bool success, Failure? failure})> deleteNote(int id);
  Future<({int count, Failure? failure})> countDirty();
  Future<({int syncedCount, Failure? failure})> syncNotes();
}
```

### 3. Data Model & Implementasi Repository

- **`NoteModel` ([lib/features/notes/data/models/note_model.dart](lib/features/notes/data/models/note_model.dart)):**  
  Menjadi jembatan antara domain dan dunia luar (SQLite). Membungkus method `toMap()`, `fromMap()`, serta konversi eksplisit `toEntity()` dan `fromEntity()`.
- **`NoteRepositoryImpl` ([lib/features/notes/data/repositories/note_repository_impl.dart](lib/features/notes/data/repositories/note_repository_impl.dart)):**  
  Mengimplementasikan `NoteRepository`. Menerima injeksi *database opener* `openDb` dan instance client HTTP `Dio`. Seluruh error ditangkap (*try-catch*) dan dipetakan menjadi `LocalFailure` atau `NetworkFailure`.

### 4. Operasi Bisnis (Use Cases)

Setiap operasi bisnis penting diisolasi ke dalam kelas tersendiri yang hanya memiliki satu alasan untuk berubah (*Single Responsibility Principle*):
- **`GetNotes`:** Mengambil daftar catatan dari repository.
- **`AddNote`:** Menerapkan validasi bisnis (menolak judul kosong dengan `ValidationFailure`) sebelum menyimpan ke repository.
- **`UpdateNote`:** Memastikan integritas data catatan saat diperbarui.
- **`DeleteNote`:** Menghapus catatan berdasarkan ID.
- **`SyncNotes`:** Memicu sinkronisasi data *dirty* ke server remote melalui repository.

---

## 🚀 Praktikum 3: Presentation, DI, dan Verifikasi

### 1. Dependency Injection dengan Riverpod

Seluruh rantai dependensi disusun secara deklaratif pada [lib/features/notes/presentation/providers/notes_providers.dart](lib/features/notes/presentation/providers/notes_providers.dart):

```dart
// 1. Data Layer: Repository diinjeksi fungsi pembuka database
final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepositoryImpl(openDb: openNotesDb);
});

// 2. Domain Layer: Use cases menerima interface NoteRepository (bukan konkrit)
final getNotesProvider = Provider<GetNotes>((ref) {
  return GetNotes(ref.watch(noteRepositoryProvider));
});

// 3. Presentation Layer: State manajemen reaktif AsyncNotifier
final notesProvider =
    AsyncNotifierProvider<NotesNotifier, List<Note>>(NotesNotifier.new);
```

### 2. Antarmuka Halaman Bersih

- [lib/features/notes/presentation/pages/notes_page.dart](lib/features/notes/presentation/pages/notes_page.dart): Menampilkan daftar catatan, indikator *badge* jumlah catatan belum sinkron (*dirty count*), tombol sinkronisasi batch, dan FAB navigasi ke form baru.
- [lib/features/notes/presentation/pages/note_detail_page.dart](lib/features/notes/presentation/pages/note_detail_page.dart): Mengelola input judul dan isi catatan dengan form validation, indikator status sinkronisasi, dan tombol simpan reaktif.
- [lib/features/notes/presentation/widgets/note_tile.dart](lib/features/notes/presentation/widgets/note_tile.dart): Komponen kartu UI yang memanfaatkan helper murni `formatDateTime()` dan `formatDirtyStatus()` dari `lib/core/format.dart`.

---

## 🔍 Hasil Verifikasi Sterilitas & Automated Testing

### 1. Tiga Pemeriksaan Sterilitas (Dependency Rule Verification)

Pemeriksaan sterilitas dilakukan menggunakan command pencarian otomatis untuk memastikan arah panah dependensi benar-benar murni:

```powershell
# 1. Presentation steril dari data mentah:
Get-ChildItem -Path "lib\features\*\presentation" -Recurse -Filter "*.dart" | `
  Select-String -Pattern "Dio\(|openDatabase|getDatabasesPath|FlutterSecureStorage|SharedPreferences\.getInstance|jsonDecode"

# 2. Logika bisnis di presentation (DateFormat, jsonDecode, toIso8601String):
Get-ChildItem -Path "lib\features\*\presentation" -Recurse -Filter "*.dart" | `
  Select-String -Pattern "DateFormat|jsonDecode|\.toIso8601String"

# 3. Domain steril dari framework & library luar:
Get-ChildItem -Path "lib\features\*\domain", "lib\core" -Recurse -Filter "*.dart" | `
  Select-String -Pattern "import 'package:flutter|import 'package:dio|import 'package:sqflite|import 'package:firebase"
```

**Hasil Eksekusi Verifikasi:**
```
Presentation raw data matches:       0 (LOLOS - 0 temuan)
Presentation business logic matches: 0 (LOLOS - 0 temuan)
Domain framework/package matches:    0 (LOLOS - 0 temuan)
```

### 2. Static Analysis (`flutter analyze`)

```bash
$ flutter analyze
Analyzing 07-week-7-clean-architecture...                       
No issues found! (ran in 1.5s)
```

### 3. Automated Test Suite (`flutter test`)

Seluruh 20 automated tests mencakup pengujian entitas, model data serialisasi, use cases dengan Fake Repository, Riverpod DI override, dan Widget rendering berhasil lulus 100%:

```bash
$ flutter test
00:00 +0: loading test/format_test.dart
00:00 +1: Core Formatting Pure Helpers formatDateTime produces correct zero-padded string
00:00 +2: Core Formatting Pure Helpers formatDateShort formats date only
00:00 +3: Core Formatting Pure Helpers formatDirtyStatus differentiates dirty and clean state
00:00 +4: Core Formatting Pure Helpers calculateWordCount counts words correctly
00:00 +5: GetNotes meneruskan daftar dari repository
00:00 +6: GetNotes meneruskan failure tanpa melempar
00:00 +7: NoteModel Data Layer Mapping fromMap creates valid NoteModel with fallback defaults
00:00 +8: NoteModel Data Layer Mapping fromMap handles missing or null fields gracefully
00:00 +9: NoteModel Data Layer Mapping toMap converts NoteModel into valid SQLite key-value map
00:00 +10: NoteModel Data Layer Mapping toEntity converts NoteModel into pure Domain Entity Note
00:00 +11: NoteModel Data Layer Mapping fromEntity creates NoteModel from pure Domain Entity
00:01 +12: Riverpod noteRepositoryProvider overrides cleanly with in-memory repository
00:01 +13: AddNote UseCase validates empty title and returns ValidationFailure
00:01 +14: AddNote UseCase adds note successfully when valid title is provided
00:01 +15: UpdateNote UseCase validates empty title on update
00:01 +16: UpdateNote UseCase updates note successfully
00:01 +17: DeleteNote UseCase deletes note by id
00:01 +18: SyncNotes UseCase syncs dirty notes and clears dirty flag
00:01 +19: SyncNotes UseCase returns NetworkFailure on error
00:05 +20: NotesPage renders note cards cleanly
00:05 +20: All tests passed!
```

---

## 💡 Refleksi Arsitektur & Jawaban Pertanyaan Jobsheet

### 1. Mengapa interface repository harus tinggal di domain, bukan di data? Apa yang rusak bila dibalik?
Jika *interface* ditaruh di layer `data`, maka layer `domain` akan terpaksa mengimpor layer `data` untuk mengetahui tipe repository tersebut. Hal ini melanggar aturan emas dependensi (*Dependency Rule: dependensi hanya mengarah ke dalam*).  
Akibatnya:
- Domain menjadi tidak murni (*terikat* pada pustaka data luar).
- Tidak mungkin melakukan unit test pada domain tanpa melibatkan dependensi data.
- Menukar database (misal dari SQLite ke Hive / ObjectBox) akan merusak domain.  
Dengan meletakkan interface di `domain`, domain yang mendikte kebutuhan kontrak bisnisnya, dan layer `data` tunduk mengimplementasikan kontrak tersebut (*Inversi Dependensi*).

### 2. Kapan use case benar-benar dibutuhkan, dan kapan repository langsung ke notifier sudah cukup?
- **Use case benar-benar dibutuhkan saat:**
  1. Terdapat aturan validasi bisnis (misal: validasi panjang karakter, format judul, otorisasi peran pengguna).
  2. Terdapat orkestrasi lintas beberapa repository (misal: mengambil user dari `AuthRepository` lalu mengambil daftar pesanan dari `OrderRepository`).
  3. Terdapat logika bisnis kompleks seperti sinkronisasi batch bertahap (*offline-to-online sync algorithm*).
- **Repository langsung ke notifier cukup saat:**
  - Operasi berupa *passthrough CRUD* satu baris yang murni mengambil atau menampilkan data tanpa transformasi atau validasi tambahan (misal: pembacaan data sederhana berdasarkan ID atau penghitungan counter baris).

### 3. Apa biaya over-engineering (use case per CRUD satu-baris) bagi tim kecil? Kapan biayanya sepadan?
- **Biaya bagi tim kecil:** Terjadi ledakan jumlah file (*class explosion*), duplikasi deklarasi boilerplate, beban navigasi kode yang berlebihan (*mental overhead*), dan waktu pengiriman fitur (*time-to-market*) yang melambat karena harus membuat 3-4 file baru hanya untuk operasi baca 1 baris.
- **Kapan sepadan:** Saat aplikasi dikerjakan oleh tim besar dengan pembagian peran yang ketat, modul memiliki tingkat kompleksitas aturan bisnis yang sering berubah, atau aplikasi membutuhkan kepatuhan pengujian ketat (*enterprise-grade financial / healthcare systems*).

### 4. Bagian mana dari usulan AI yang Anda tolak atau sederhanakan, dan mengapa?
- **Ditolak/Disederhanakan:** Usulan AI yang membuat file use case terpisah untuk setiap metode mikro seperti `CountDirtyUseCase` dan `GetNoteByIdUseCase`.
- **Alasan Teknis:** Operasi tersebut adalah *read-only passthrough* langsung ke repository tanpa aturan bisnis. Memaksakan use case untuk keduanya hanya membuang waktu dan menambah file tanpa manfaat nyata. Pemanggilan didelegasikan langsung melalui notifier/provider terisolasi dengan kontrak `NoteRepository`.

---

## 📸 Tangkapan Layar Aplikasi (Screenshots)

Berikut tangkapan layar fungsionalitas aplikasi setelah dilakukan refaktorisasi Clean Architecture:

| Daftar Catatan Offline (Dirty Indicator) | Sinkronisasi Sukses (Dirty = 0) | Mode Gelap (Dark Mode) |
|:---:|:---:|:---:|
| ![Catatan Dirty](screenshots/01_offline_notes_dirty.png) | ![Catatan Tersinkron](screenshots/02_offline_notes_synced.png) | ![Dark Mode](screenshots/05_notes_dark_mode_dirty.png) |

---

## 🛠️ Cara Menjalankan & Menguji Proyek

1. **Pindah ke direktori minggu 7:**
   ```bash
   cd 07-week-7-clean-architecture
   ```
2. **Unduh dependensi pub:**
   ```bash
   flutter pub get
   ```
3. **Jalankan analisis statis:**
   ```bash
   flutter analyze
   ```
4. **Jalankan automated test suite:**
   ```bash
   flutter test
   ```
5. **Jalankan aplikasi di emulator atau desktop:**
   ```bash
   flutter run -d windows # atau chrome / android
   ```

