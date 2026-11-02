# Week 9 – AI-Assisted Development / Vibe Coding

> **Jobsheet:** [#09 AI-Assisted Development](https://jti-polinema.github.io/flutter-codelab/09-minggu-9-ai-assisted-development-vibe-coding/)

---

## Fitur

Proyek ini melanjutkan aplikasi catatan offline Clean Architecture dari Minggu 7, dengan **tambahan fitur pencarian judul catatan** yang dikembangkan menggunakan AI-assisted development workflow.

| Fitur | Deskripsi |
|-------|-----------|
| **Search Bar** | Cari catatan berdasarkan judul (case-insensitive, real-time) |
| **Highlight hasil** | Teks yang cocok dengan query di-highlight kuning di `NoteTile` |
| **Empty state dinamis** | Pesan berbeda: "belum ada catatan" vs "tidak ditemukan untuk query X" |
| **Clear search** | Tombol X di search bar + tombol "Hapus Pencarian" di empty state |
| **CRUD Notes** | Tambah, edit, hapus catatan (SQLite lokal) |
| **Sync** | Sinkronisasi catatan dirty ke remote (JSONPlaceholder) |

---

## Stack Teknologi

| Layer | Teknologi |
|-------|-----------|
| **UI** | Flutter + Material 3 |
| **State** | Riverpod `^3.4.3` (AsyncNotifier, StateProvider, Provider) |
| **Local DB** | sqflite `^2.4.4` + sqflite_common_ffi |
| **HTTP** | Dio `^5.11.1` |
| **Routing** | go_router `^18.0.2` |
| **Arsitektur** | Clean Architecture Feature-First |

---

## Struktur Proyek

```
lib/
├── core/
│   ├── failures.dart          # Domain error types
│   └── format.dart            # Pure formatting utilities
├── features/
│   └── notes/
│       ├── data/
│       │   ├── datasources/   # SQLite openNotesDb
│       │   ├── models/        # NoteModel (serialization)
│       │   └── repositories/  # NoteRepositoryImpl
│       ├── domain/
│       │   ├── entities/      # Note (pure entity)
│       │   ├── repositories/  # NoteRepository (abstract)
│       │   └── usecases/      # GetNotes, AddNote, UpdateNote,
│       │                      # DeleteNote, SyncNotes, SearchNotes (NEW)
│       └── presentation/
│           ├── pages/         # NotesPage (+ search), NoteDetailPage
│           ├── providers/     # notes_providers (+ searchQueryProvider,
│           │                  #                   filteredNotesProvider)
│           └── widgets/       # NoteTile (+ highlight query)
├── main.dart
└── routes.dart

docs/
└── ai-log.md         # Prompt, output AI, verifikasi, debug, refactor

test/
├── search_filter_test.dart   # Unit test filterNotes + SearchNotes
└── widget_test.dart          # Widget test empty state

screenshots/
└── (lihat folder screenshots/)
```

---

## Prompt Utama (AI-Assisted)

```
Peran: senior Flutter dev.
Konteks: feature-first, Riverpod ^3.4.3, SQLite sqflite ^2.4.4, Dio ^5.11.1.
Tugas: tambah SearchNotes use case + filter provider + search bar di NotesPage.
Batas: domain bebas dari Flutter/Dio/SQLite. Maks 80 baris per file.
Output: kode + 3 test case + cara uji manual.
```

Detail prompt, output AI, verifikasi, dan keputusan terima/tolak ada di [`docs/ai-log.md`](docs/ai-log.md).

---

## Cara Menjalankan

```bash
# Install dependencies
flutter pub get

# Jalankan di Windows (development)
flutter run -d windows

# Atau di Chrome
flutter run -d chrome
```

---

## Hasil Verifikasi

```bash
# Static analysis
flutter analyze
# > No issues found!

# Unit + widget tests
flutter test
# > All tests passed!
```

### Tabel Terima/Tolak Saran AI

| # | Saran AI | Keputusan | Alasan |
|---|----------|-----------|--------|
| 1 | `notes.searchFuzzy()` | **TOLAK** | Method fiktif (grep 0 hasil, halusinasi API) |
| 2 | Filter di `NotesNotifier` (case-sensitive) | **TERIMA + Refactor** | Pindah ke domain, perbaiki case-sensitivity |
| 3 | Empty state tidak dibedakan | **TERIMA** | 2 pesan berbeda di `NotesPage` |
| 4 | Gunakan `StreamProvider` untuk search | **TOLAK** | `StateProvider` cukup; Stream menambah kompleksitas tanpa manfaat |

---

## Halusinasi AI yang Ditemukan

**Method:** `notes.searchFuzzy(query)`

**Bukti:**
```bash
grep -r "searchFuzzy" lib/
# > 0 match
```
Autocomplete IDE tidak menampilkan `searchFuzzy` di `List<Note>`. Method ini tidak ada di Dart SDK maupun paket sqflite.

**Keputusan:** TOLAK → Diganti dengan fungsi murni `filterNotes` di `domain/usecases/search_notes.dart`.

---

## Mahasiswa

| Informasi | Detail |
|-----------|--------|
| **Nama** | Yanuar Ramadhani Kuswoko |
| **NIM** | 244107020172 |
| **Mata Kuliah** | Pemrograman Mobile |
| **Minggu** | 9 – AI-Assisted Development |
