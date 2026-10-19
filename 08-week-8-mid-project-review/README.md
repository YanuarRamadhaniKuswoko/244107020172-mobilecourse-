# Week 8 – Mid Project Review & Code Review

**Nama**: Yanuar Ramadhani Kuswoko  
**NIM**: 244107020172  
**Mata Kuliah**: Pemrograman Mobile  
**Tanggal**: 19 Oktober 2026

---

## Deskripsi

Minggu 8 berfokus pada **review kode pertengahan semester** menggunakan Git Flow, conventional commits, static analysis, dan peer review terstruktur. Project yang direview adalah hasil Minggu 7 (Clean Architecture Notes).

## Tujuan Pembelajaran

- Menjelaskan Git Flow dan strategi branching (`main`, `develop`, `feature/*`, `fix/*`)
- Menulis commit dan Pull Request yang berkualitas dengan format konvensional
- Melakukan peer code review yang konstruktif dengan checklist terstruktur
- Menjalankan static analysis dan formatter (`flutter analyze`, `dart format`) hingga bersih
- Menilai kesiapan project tengah semester dan menindaklanjuti hasil review
- Memverifikasi saran review dari AI sebelum diterapkan

## Struktur Folder

```
08-week-8-mid-project-review/
├── docs/
│   └── review-checklist.md   ← Checklist lengkap review (Praktikum 1–4)
├── screenshots/              ← Screenshot hasil review (opsional)
└── README.md                 ← File ini
```

> Project utama yang direview berada di `../07-week-7-clean-architecture/`

## Ringkasan Praktikum

### Praktikum 1 – Hygiene Branch dan Commit

1. **Audit riwayat** menggunakan `git log --oneline -15`, `git branch -a`, dan `git status`
2. **Buat branch kerja**: `develop` → `feat/week8-code-review`
3. **Tabel before/after** 3 commit buruk yang diperbaiki ke format konvensional

### Praktikum 2 – Checklist Code Review

Review terstruktur dengan 20 item meliputi:
- Struktur folder (feature-first)
- Dependency Rule Clean Architecture
- Null safety dan error handling
- State management (Riverpod)
- Validasi form
- Penamaan (naming conventions)
- Widget composition
- Unit test dan widget test
- Static analysis dan formatter
- Git hygiene

**Temuan utama**: Tidak ada validasi max-length pada judul catatan → diperbaiki.

### Praktikum 3 – Static Analysis dan Formatter

| Alat | Hasil |
|------|-------|
| `flutter analyze` | ✅ No issues found! |
| `dart format` | ✅ Bersih (23 file diformat sebelumnya, kini clean) |
| `flutter test` | ✅ 20 tests passed |

### Praktikum 4 – Verifikasi Saran AI

AI digunakan sebagai reviewer awal, **bukan** pengganti keputusan.  
Setiap saran diverifikasi secara manual sebelum diterapkan.

| Saran AI | Keputusan | Alasan |
|----------|-----------|--------|
| Tambah validasi max-length 100 karakter | ✅ DITERIMA | Wajar untuk UX dan data integrity |
| Refactor `_buildScaffold` jadi widget terpisah | ❌ DITOLAK | Method hanya dipakai 1 class, tidak ada duplikasi |
| `const` constructor di widget stateless | ✅ SUDAH ADA | Tidak perlu tindakan |
| Ganti `Navigator.pop` dengan `context.pop()` | ✅ DITERIMA | Konsisten dengan go_router |

## Git Flow yang Diterapkan

```
main           → selalu rilis, dilindungi (semua commit lama)
  └── develop  → integrasi fitur mingguan (dibuat minggu 8)
        └── feat/week8-code-review  → branch minggu 8 ini
```

### Log Commit di Branch Ini

```
a9f3360 fix(notes): tambah validasi max-length 100 karakter pada judul
9290b2e chore(week7): format semua file dengan dart format
```

## Referensi

- [Jobsheet #08 – Mid Project Review & Code Review](https://jti-polinema.github.io/flutter-codelab/08-minggu-8-mid-project-review-code-review/)
- [Review Checklist Lengkap](docs/review-checklist.md)
- [Project Week 7 yang Direview](../07-week-7-clean-architecture/)
