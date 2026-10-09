# AI Challenge Log & Architecture Justification

**Mata Kuliah:** Pemrograman Mobile  
**Minggu:** 07  
**Topik:** Clean Architecture & Feature-First Refactoring  
**Nama Mahasiswa:** Yanuar Ramadhani Kuswoko  
**NIM:** 244107020176  
**Kelas / Absen:** TI-2D / 25  

---

## 1. AI Prompt Challenge

Berikut prompt yang diajukan ke AI Coding Assistant sesuai panduan Jobsheet Minggu 7:

```text
Project Flutter saya: offline_notes / campus_notify (catatan offline / auth + FCM + daftar pengumuman).
Kondisi kini: folder lib/{data, providers, pages, widgets},
repository tercampur dengan implementasi, widget/notifier memanggil SQLite/Dio langsung.
Tugas:
1. Usulkan struktur feature-first Clean Architecture
   (presentation/domain/data) untuk fitur notes/announcements.
2. Untuk tiap file lama, sebutkan tujuan barunya (pindah/pecah/hapus).
3. Tandai bagian yang over-engineering bila diterapkan ke CRUD sederhana,
   dan kapan use case benar-benar dibutuhkan vs repository langsung.
4. Tunjukkan wiring DI dengan Riverpod (tanpa package DI tambahan).
Jelaskan trade-off setiap keputusan.
```

---

## 2. Output Respon Awal AI (Raw Proposal)

Respon awal yang diusulkan oleh AI asisten:

```text
1. Struktur Usulan AI:
lib/
├── core/
│   ├── failures.dart
│   └── format.dart
├── features/
│   └── notes/
│       ├── domain/
│       │   ├── entities/note.dart
│       │   ├── repositories/note_repository.dart
│       │   └── usecases/
│       │       ├── get_notes.dart
│       │       ├── get_note_by_id.dart
│       │       ├── add_note.dart
│       │       ├── update_note.dart
│       │       ├── delete_note.dart
│       │       ├── count_dirty.dart
│       │       └── sync_notes.dart
│       ├── data/
│       │   ├── datasources/notes_database.dart
│       │   ├── models/note_model.dart
│       │   └── repositories/note_repository_impl.dart
│       └── presentation/
│           ├── providers/notes_providers.dart
│           ├── pages/
│           │   ├── notes_page.dart
│           │   └── note_detail_page.dart
│           └── widgets/note_tile.dart
├── routes.dart
└── main.dart

2. Pemetaan File Lama ke Baru:
- lib/data/local/note.dart dipecah menjadi:
  * lib/features/notes/domain/entities/note.dart (Entity murni tanpa toMap/fromMap)
  * lib/features/notes/data/models/note_model.dart (Data model dengan toMap, fromMap, toEntity)
- lib/data/repositories/note_repository.dart dipecah menjadi:
  * lib/features/notes/domain/repositories/note_repository.dart (Interface abstrak)
  * lib/features/notes/data/repositories/note_repository_impl.dart (Implementasi SQLite & Dio)
- lib/data/local/db.dart dipindah ke:
  * lib/features/notes/data/datasources/notes_database.dart
- lib/data/providers.dart dipindah dan disusun ulang ke:
  * lib/features/notes/presentation/providers/notes_providers.dart (DI Riverpod terpusat)
- lib/pages/ & lib/widgets/ dipindah ke:
  * lib/features/notes/presentation/pages/ & widgets/

3. Analisis Over-Engineering:
- AI mengusulkan pembuatan file Use Case terpisah untuk setiap metode (bahkan untuk countDirty dan getNoteById satu baris).
- Pada aplikasi CRUD kecil, membuat kelas Use Case per baris operasi CRUD menambah boilerplate (class explosion).
- Use Case esensial bila terdapat aturan bisnis/validasi atau agregasi data lintas repository (misal: validasi judul kosong sebelum simpan, orkestrasi sinkronisasi dirty notes ke REST API Dio).
```

---

## 3. Evaluasi Kritis & Tabel Usulan vs Keputusan Final

| Komponen Arsitektur | Usulan Awal AI | Keputusan Final Pengembang | Justifikasi & Trade-Off Teknis |
|---|---|---|---|
| **Pemisahan Entity & Model** | `Note` entity murni dan `NoteModel` turunan dengan serialisasi. | **Diterima Sepenuhnya** | Entity di layer domain tidak boleh tercemar format penyimpanan luar (`Map<String, dynamic>`, JSON, SQLite cursor). Model di layer data bertanggung jawab atas serialisasi dan konversi `.toEntity()`. |
| **Lokasi Interface Repository** | `NoteRepository` (abstract) diletakkan di `domain/repositories/`. | **Diterima Sepenuhnya** | Memenuhi *Dependency Inversion Principle (DIP)*. Domain mendikte kontrak yang dibutuhkan, Data mengimplementasikan. |
| **Granularitas Use Case** | Membuat use case terpisah untuk: `GetNotes`, `GetNoteById`, `AddNote`, `UpdateNote`, `DeleteNote`, `CountDirty`, `SyncNotes`. | **Disederhanakan & Disesuaikan** | Untuk operasi transparan 1 baris seperti `countDirty` dan `getNoteById`, notifier dapat langsung memanggil abstraksi `NoteRepository`. Use case difokuskan pada operasi dengan aturan bisnis (mis. validasi `AddNote`, `UpdateNote`, orkestrasi batch `SyncNotes`, dan `GetNotes`). Menghindari *class explosion* yang tidak memberikan nilai tambah. |
| **Penanganan Error / Failure** | Return record `({T? data, Failure? failure})` alih-alih melempar exception mentah. | **Diterima Sepenuhnya** | Menghindari kebocoran exception SQLite/Dio ke presentation. UI hanya menerima kegagalan yang aman dan ramah pengguna melalui objek `Failure` turunan (`LocalFailure`, `NetworkFailure`, `ValidationFailure`). |
| **Ekstraksi Helper Murni** | Format tanggal diekstrak ke `lib/core/format.dart`. | **Diterima Sepenuhnya** | Menghilangkan pelanggaran logika bisnis di dalam `build()`. Fungsi format dapat diuji dengan unit test murni tanpa widget context. |
| **DI Tanpa Service Locator** | Riverpod Provider wiring di `notes_providers.dart`. | **Diterima Sepenuhnya** | Tidak memerlukan package pihak ketiga seperti `get_it`. Memudahkan mocking/fake repository saat testing dengan `overrideWithValue`. |

---

## 4. AI Verification Checklist

Berikut checklist verifikasi ketat sebelum kode diterima dan digabungkan:

- [x] **Interface repository tinggal di domain dan implementasi di data?**  
  *Status:* Lolos. `NoteRepository` ada di `domain/repositories/note_repository.dart` dan `NoteRepositoryImpl` ada di `data/repositories/note_repository_impl.dart`.
- [x] **Domain steril dari framework Flutter, Dio, SQLite, dan Firebase?**  
  *Status:* Lolos. Diperiksa dengan grep otomatis: 0 temuan.
- [x] **Apakah entity bebas dari mapping (`toMap`/`fromMap`/`toJson`)?**  
  *Status:* Lolos. Mapping hanya ada pada `NoteModel` di layer data.
- [x] **Presentation steril dari database mentah, Dio, dan format tanggal mentah?**  
  *Status:* Lolos. Diperiksa dengan grep otomatis: 0 temuan.
- [x] **Wiring DI terpusat di Provider dan widget tidak pernah memanggil `new Repository()` langsung?**  
  *Status:* Lolos. Seluruh instansiasi disuntikkan lewat `noteRepositoryProvider`.
- [x] **Static analysis & Test hijau?**  
  *Status:* Lolos. `flutter analyze` 0 issue, `flutter test` seluruh test lulus 100%.

