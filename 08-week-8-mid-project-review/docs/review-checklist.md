# Review Checklist – Mid Project (Week 8)

**Nama**: Yanuar Ramadhani Kuswoko  
**NIM**: 244107020172  
**Tanggal**: 19 Oktober 2026  
**Project**: Clean Architecture Notes (Week 7 → Week 8 review)

---

## Praktikum 1 – Hygiene Branch dan Commit

### 1. Audit Riwayat (git log --oneline -15)

```
6d2dd68 Jobsheet Pemrograman Mobile
f601f9d fix: update NIM dari 244107020176 menjadi 244107020172
7f45c08 jobsheet week-7
afca650 jobsheet minggu-6
cff2290 jobsheet minggu-5
d816486 jobsheet minggu 4
a89874d Tugas_Week3
e79a463 jobsheet minggu 2
4c41135 jobsheet minggu 2
300abf7 jobsheet minggu 1
```

**Masalah yang ditemukan:**
- Semua commit langsung ke `main` (tidak ada branch fitur)
- Pesan commit tidak mengikuti format konvensional (`jobsheet week-7`, `update`)
- Tidak ada branch `develop`

### 2. Branch Kerja yang Benar

```bash
git checkout -b develop          # buat branch integrasi
git checkout -b feat/week8-code-review   # branch fitur minggu 8
# ... kerjakan perubahan ...
git add -p
git commit -m "chore(week7): format semua file dengan dart format"
```

### 3. Perbaikan Commit Buruk (Before/After)

| # | Pesan Commit Lama (Buruk) | Pesan Commit Baru (Konvensional) | Alasan |
|---|---------------------------|-----------------------------------|--------|
| 1 | `jobsheet week-7` | `feat(week7): implementasi Clean Architecture notes dengan Riverpod` | Tidak menjelaskan apa yang dilakukan; versi baru menyebut tipe (feat), scope (week7), dan isi perubahan |
| 2 | `fix: update NIM dari 244107020176 menjadi 244107020172` | `fix(meta): koreksi NIM pada seluruh README (244107020176 → 244107020172)` | Sudah ada tipe, tapi scope tidak ada dan kurang spesifik; versi baru menambah scope dan detail file yang diubah |
| 3 | `Jobsheet Pemrograman Mobile` | `docs: tambah README utama daftar isi seluruh week 1-16` | Pesan sama sekali tidak informatif; versi baru menjelaskan tipe (docs) dan isi konkret perubahan |

---

## Praktikum 2 – Checklist Code Review

### Checklist Terstruktur

| Kategori | Item Review | Status | Catatan |
|----------|-------------|--------|---------|
| **Struktur** | Feature-first folder terpenuhi (data/domain/presentation) | ✅ LULUS | Semua fitur terstruktur di `features/notes/` |
| **Struktur** | `core/` hanya berisi utilities, bukan logika bisnis | ✅ LULUS | `core/failures.dart` dan `core/format.dart` bersih |
| **Dependency Rule** | Domain TIDAK mengimpor Data atau Presentation | ✅ LULUS | Entity dan use case hanya bergantung pada abstract `NoteRepository` |
| **Dependency Rule** | Data TIDAK mengimpor Presentation | ✅ LULUS | `NoteRepositoryImpl` hanya impor domain dan core |
| **Null Safety** | Nullable diakses dengan `?.` atau `??`, bukan `!` tanpa guard | ✅ LULUS | Semua akses nullable aman di seluruh codebase |
| **Error Handling** | Semua async function di-wrap try-catch | ✅ LULUS | Repository impl menggunakan try-catch di setiap method |
| **Error Handling** | Error ditampilkan ke user (bukan hanya print) | ✅ LULUS | Semua error ditampilkan via SnackBar |
| **State Mgmt** | Tidak ada setState berlebihan di ConsumerWidget | ✅ LULUS | Hanya `_isSyncing` dan `_isSaving` (state UI lokal sah) |
| **State Mgmt** | Provider tidak monolitik | ✅ LULUS | Dipisah: `notesProvider`, `dirtyCountProvider`, `noteDetailProvider` |
| **Validasi** | Form validasi judul tidak boleh kosong | ✅ LULUS | Ada `validator` di `TextFormField` judul |
| **Validasi** | Validasi max-length judul | ❌ BELUM ADA | Perlu ditambah batas panjang judul (maks 100 karakter) |
| **Penamaan** | Class PascalCase, variable camelCase, file snake_case | ✅ LULUS | Konsisten di seluruh codebase |
| **Widget** | Nesting widget tidak terlalu dalam (≤7 level) | ✅ LULUS | `_buildScaffold` memecah widget agar tidak terlalu dalam |
| **Widget** | Widget reusable dipisah ke `widgets/` | ✅ LULUS | `NoteTile` ada di `presentation/widgets/` |
| **Test** | Unit test domain use case ada | ✅ LULUS | `usecases_test.dart`, `get_notes_test.dart` tersedia |
| **Test** | Unit test model ada | ✅ LULUS | `note_model_test.dart` tersedia |
| **Test** | Widget test ada | ✅ LULUS | `widget_test.dart` tersedia |
| **Static Analysis** | `flutter analyze` bersih (0 issue) | ✅ LULUS | "No issues found! (ran in 2.3s)" |
| **Formatter** | `dart format --output=none` tidak ada perubahan | ✅ LULUS | Diperbaiki dengan `dart format .` + commit |
| **Git** | Pesan commit menggunakan format konvensional | ⚠️ DIPERBAIKI | Mulai minggu 8 sudah konvensional |

### Temuan dan Tindak Lanjut

| # | Temuan | Tingkat | Status Tindak Lanjut |
|---|--------|---------|----------------------|
| 1 | Semua commit lama langsung ke `main` tanpa branch fitur | Sedang | ✅ Diperbaiki: pakai `develop` → `feat/*` mulai minggu 8 |
| 2 | `dart format` belum dijalankan sejak proyek dimulai | Rendah | ✅ Diperbaiki: commit `chore(week7): format semua file dengan dart format` |
| 3 | Pesan commit lama tidak informatif | Rendah | ✅ Didokumentasikan: tabel before/after di Praktikum 1 |
| 4 | Tidak ada validasi max-length judul catatan | Rendah | ✅ Diperbaiki: `fix(notes): tambah validasi max-length 100 karakter pada judul` |

---

## Praktikum 3 – Static Analysis dan Formatter

### Hasil `flutter analyze`

```
Analyzing 07-week-7-clean-architecture...
No issues found! (ran in 2.3s)
```

**Status**: ✅ BERSIH — 0 peringatan, 0 error

### Hasil `dart format --output=none --set-exit-if-changed .` (Sebelum perbaikan)

```
Changed lib/core/failures.dart
Changed lib/features/notes/data/datasources/notes_database.dart
Changed lib/features/notes/data/models/note_model.dart
... (23 file berubah)
Formatted 24 files (23 changed) in 0.14 seconds.
```

**Status**: ⚠️ ADA PERUBAHAN — 23 file perlu diformat

### Setelah `dart format .`

```
Formatted 24 files (23 changed) in 0.15 seconds.
```

**Status**: ✅ BERSIH — semua file sudah terformat

### Hasil `flutter test`

```
00:01 +20: All tests passed!
```

**Status**: ✅ HIJAU — 20 test lulus, 0 gagal

---

## Praktikum 4 – Verifikasi Saran AI

> **Kebijakan**: AI digunakan sebagai reviewer awal. Setiap saran diverifikasi secara manual sebelum diterapkan.

### Saran AI yang Dievaluasi

| Saran AI | Verifikasi Manual | Keputusan | Alasan Keputusan |
|----------|------------------|-----------|------------------|
| Tambah validasi max-length judul (maks 100 karakter) | Dicek `NoteDetailPage` validator: hanya cek kosong, belum ada batas panjang | **DITERIMA** | Wajar untuk UX dan mencegah data truncation di SQLite TEXT |
| Refactor `_buildScaffold` menjadi widget terpisah `NoteFormWidget` | Dicek: `_buildScaffold` hanya dipanggil di 1 class, tidak ada duplikasi | **DITOLAK** | Ekstraksi akan menambah kompleksitas tanpa manfaat nyata; private method sudah cukup |
| Tambah `const` constructor di semua widget stateless | Dicek kode: semua `StatelessWidget` sudah punya `const` constructor | **SUDAH ADA** | Tidak perlu tindakan tambahan |
| Ganti `Navigator.pop` dengan `context.pop()` dari go_router | Dicek: `note_detail_page.dart` pakai `Navigator.of(context).pop()` | **DITERIMA** | Konsisten dengan go_router yang sudah dipakai |

### Perubahan yang Diimplementasikan

1. **`fix(notes): tambah validasi max-length 100 karakter pada judul`**
   - File: `lib/features/notes/presentation/pages/note_detail_page.dart`
   - Perubahan: tambah kondisi `val.trim().length > 100` di validator judul
   - Verifikasi: dicek manual bahwa logika benar dan tidak memecah test yang ada

2. **`fix(notes): ganti Navigator.pop dengan context.pop di NoteDetailPage`**
   - File: `lib/features/notes/presentation/pages/note_detail_page.dart`
   - Perubahan: `Navigator.of(context).pop()` → `context.pop()`
   - Verifikasi: dicek bahwa `go_router` sudah diimpor dan `context.pop()` tersedia

---

## Ringkasan Kesiapan Mid-Project

| Aspek | Nilai (1–5) | Catatan |
|-------|-------------|---------|
| Arsitektur (Clean Arch) | 5 | Feature-first terpenuhi penuh, dependency rule bersih |
| Kualitas Kode | 5 | `flutter analyze` bersih, `dart format` bersih |
| Testing | 4 | 20 test lulus; bisa ditambah integration test |
| Git Hygiene | 3 | Diperbaiki mulai minggu 8 dengan Git Flow |
| Dokumentasi | 4 | README ada; docs/review-checklist.md baru ditambahkan |

**Kesimpulan**: Project siap untuk demo mid-semester. Perbaikan utama yang sudah dilakukan: dart format konsisten, validasi form lebih lengkap, Git Flow diterapkan mulai minggu 8.
