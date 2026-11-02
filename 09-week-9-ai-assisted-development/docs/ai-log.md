# AI Log – Minggu 9: AI-Assisted Development

> **Kebijakan:** AI boleh mengusulkan kode, tetapi setiap baris dibaca, diverifikasi API, diuji, di-refactor, dan dapat dijelaskan tanpa membuka AI kembali.

---

## 1. Prompt Engineering (Praktikum 1)

### Formula 5 Slot

```
Peran   : senior Flutter dev
Konteks : feature-first, Riverpod ^3.4.3, SQLite (sqflite ^2.4.4) + Dio ^5.11.1
           Struktur: presentation -> domain <- data
           Existing use cases: GetNotes, AddNote, UpdateNote, DeleteNote, SyncNotes
Tugas   : Tambah pencarian judul notes + empty state
           (query kosong = semua, query tak cocok = empty state khusus)
Batas   : jangan ubah arsitektur, jangan panggil SQLite dari widget, maks 80 baris per file
Output  : kode domain use case + provider + UI update + 3 test case + cara uji manual
```

### Prompt Buruk vs Baik

| | Contoh |
|---|---|
| **Buruk** | "buatkan search notes yang keren" |
| **Baik** | "Tambah search judul notes. Arsitektur: presentation->domain<-data. Jangan panggil SQLite dari widget. Sertakan empty state + 1 widget test." |

### Konteks yang Disertakan ke AI

- Struktur folder (`lib/features/notes/domain/`, `data/`, `presentation/`)
- Kontrak `NoteRepository` (method signatures)
- Versi package dari `pubspec.yaml`
- File `search_notes.dart` **tidak** ada — AI harus membuat dari nol

### Yang **TIDAK** Disertakan

- Token FCM, JWT, API key (diganti `TOKEN_PLACEHOLDER`)
- Seluruh repo 500+ file

---

## 2. Output AI Mentah (Praktikum 2)

### Prompt yang Dikirim

```
Peran: senior Flutter dev.
Konteks: feature-first, Riverpod ^3.4.3, SQLite sqflite ^2.4.4, Dio ^5.11.1.
Tugas: tambah SearchNotes use case + filter provider + search bar di NotesPage.
Batas: domain bebas dari Flutter/Dio/SQLite. Maks 80 baris per file.
Output: kode + 3 test case + cara uji manual.

Arsitektur saat ini:
domain/usecases: GetNotes, AddNote, UpdateNote, DeleteNote, SyncNotes
domain/entities: Note
domain/repositories: NoteRepository (abstract)
presentation/providers: notesProvider, dirtyCountProvider, noteDetailProvider
```

### Output Awal AI (Sebelum Review)

```dart
// AI mengusulkan di widget NotesPage:
final filtered = notes.searchFuzzy(query);  // HALUSINASI: method tidak ada
```

```dart
// AI juga mengusulkan filter di notifier (bukan domain use case):
class NotesNotifier extends AsyncNotifier<List<Note>> {
  List<Note> search(List<Note> notes, String q) =>
    notes.where((n) => n.title.contains(q)).toList(); // case-sensitive bug
}
```

---

## 3. Verifikasi 6 Langkah (Praktikum 2)

### Langkah 1 – Baca Tiap Baris

Ditandai baris yang belum dipahami:
- `notes.searchFuzzy()` — **tidak dipahami**, tidak ada di autocomplete

### Langkah 2 – Cek Import

Domain layer hanya berisi:
```
import '../entities/note.dart';   // pure domain entity
```
Tidak ada import Flutter/Dio/SQLite di `search_notes.dart` ✅

### Langkah 3 – Cek API (Bukti Halusinasi #1)

**Temuan:** `notes.searchFuzzy(query)` – method fiktif.

**Bukti:**
```powershell
# grep tidak menemukan searchFuzzy
grep -r "searchFuzzy" d:\mobile\09-week-9-ai-assisted-development\
# Hasil: 0 match

# autocomplete IDE tidak menampilkan searchFuzzy di List<Note>
# pub.dev/packages/sqflite tidak ada extension searchFuzzy
```

**Keputusan: TOLAK** – diganti dengan fungsi murni `filterNotes` di domain.

### Langkah 4 – flutter analyze

```
flutter analyze
# Analyzing notes_search_ai...
# No issues found!
```

### Langkah 5 – Test (Minimal 1 sukses + 1 gagal)

```dart
// Test sukses – filter case-insensitive
test('filter abaikan huruf besar/kecil', () {
  expect(filterNotes(list, 'belanja'), hasLength(3));  // HIJAU
});

// Test gagal – query tak cocok
test('query tak cocok kembalikan kosong', () {
  expect(filterNotes(list, 'zzz-tak-ada-9999'), isEmpty);  // HIJAU
});
```

### Langkah 6 – Uji Manual

| Query | Hasil | Status |
|-------|-------|--------|
| (kosong) | Semua catatan tampil | OK |
| `belanja` | Catatan berisi "belanja" (case-insensitive) | OK |
| `BELANJA` | Sama dengan `belanja` | OK |
| `zzz-tidak-ada` | Empty state: "Tidak ada catatan dengan judul..." | OK |

---

## 4. Debug dan Refactor (Praktikum 3)

### Bug yang Ditemukan

**Bug:** Filter case-sensitive di notifier (bukan domain).

**Reproduksi:**
1. Ketik `BELANJA` di search bar
2. Catatan "Belanja Mingguan" tidak muncul

**Isolasi:**
```dart
// Sebelum (AI, case-sensitive, salah letak di notifier):
notes.where((n) => n.title.contains(query)).toList()

// Sesudah (domain use case, case-insensitive):
notes.where((n) => n.title.toLowerCase().contains(query.toLowerCase())).toList()
```

**Test merah (pembukti bug):**
```dart
test('filter abaikan huruf besar/kecil', () {
  final result = filterNotes(fixture, 'BELANJA');
  expect(result, hasLength(3)); // MERAH sebelum fix, HIJAU setelah
});
```

**Akar masalah:** AI menempatkan logika search di `NotesNotifier` (presentation) bukan domain use case — melanggar dependency rule.

**Perbaikan:** Pindah ke `SearchNotes` use case di `domain/usecases/search_notes.dart`.

### Refactor Layer

```
widget (UI saja: search bar, empty state, highlight)
  -> filteredNotesProvider (presentation: watch query + notesProvider)
  -> SearchNotes use case (domain: aturan filter case-insensitive)
  -> notesProvider / NoteRepository (fetch dari SQLite)
```

### Verifikasi Akhir

```powershell
flutter analyze                      # No issues found!
dart format --set-exit-if-changed .  # 0 perubahan
flutter test                         # All tests passed
```

---

## 5. AI Challenge – Review Kode Search

### Prompt Review

```
Review kode search Flutter ini sebagai senior dev.
Konteks: feature-first (presentation->domain<-data), Riverpod, SQLite + Dio.
Fokus: kebenaran, arsitektur, test. Abaikan style.
Beri 3 temuan + level blocker/saran + alasan.
```

### 3 Temuan AI + Tindakan

| # | Temuan AI | Level | Keputusan | Bukti/Alasan |
|---|-----------|-------|-----------|--------------|
| 1 | `notes.searchFuzzy()` tidak ada di API | Blocker | TOLAK + Tulis manual | grep 0 hasil; autocomplete tidak menampilkan |
| 2 | Filter di `NotesNotifier` melanggar Clean Architecture | Blocker | Terima + Refactor | Pindah ke `SearchNotes` domain use case |
| 3 | Empty state tidak membedakan kosong total vs hasil search kosong | Saran | Terima | 2 pesan berbeda di `NotesPage` |

### Temuan yang Ditolak dengan Alasan Teknis

**Temuan AI:** Gunakan `StreamProvider` untuk search agar lebih reaktif.

**Alasan penolakan:**
- `StateProvider<String>` untuk query + `Provider<AsyncValue<List<Note>>>` sudah cukup reaktif.
- `StreamProvider` menambah kompleksitas tanpa keuntungan nyata untuk filter sinkron.
- Memperkenalkan `StreamController` membutuhkan dispose yang tepat — sumber memory leak potensial.
- Arsitektur saat ini lulus `flutter analyze` tanpa warning.

---

## 6. Checklist Verifikasi Mandiri

- [x] Prompt 5 slot + konteks ada di bagian 1
- [x] `flutter analyze` bersih (0 issue)
- [x] `flutter test` hijau (semua test lulus)
- [x] 1 temuan AI terbukti benar via grep (`searchFuzzy`) + diperbaiki
- [x] 1 temuan AI ditolak dengan alasan teknis tertulis (`StreamProvider`)
- [x] Refactor logika filter dari notifier ke domain use case
- [x] Empty state membedakan "kosong total" vs "tidak ada hasil search"
- [x] Setiap keputusan dapat dijelaskan tanpa membuka AI

---

## 7. Refleksi

**1. Halusinasi AI yang ditemukan:**
`notes.searchFuzzy(query)` — method yang tidak ada di Dart/sqflite. Dibuktikan dengan grep dan autocomplete IDE (0 hasil). Menunjukkan AI menginterpolasi API yang terdengar logis tapi fiktif.

**2. Prompt yang paling membantu:**
Prompt dengan 5 slot eksplisit (peran, konteks versi package, tugas, batas arsitektur, output). Tanpa batasan "jangan panggil SQLite dari widget", AI langsung menaruh query di widget.

**3. Satu refactor pada kode AI:**
Pindah logika filter dari `NotesNotifier` (presentation) ke `SearchNotes` use case (domain) agar dapat diuji tanpa database dan memenuhi dependency rule Clean Architecture.

**4. Keputusan terima/tolak yang paling sulit:**
`StreamProvider` vs `StateProvider` — keduanya valid secara teknis, tapi `StateProvider` lebih sederhana dan sudah memenuhi kebutuhan. Memilih tidak over-engineer.
