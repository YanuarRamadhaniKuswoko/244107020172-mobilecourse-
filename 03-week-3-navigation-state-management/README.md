# #03 | Navigation & State Management

**Mata Kuliah:** Pemrograman Mobile  
**Minggu:** 03  
**Topik:** Declarative Navigation (GoRouter), State Management (Flutter Riverpod), AsyncValue, Refactoring, & Widget Testing  

---

## Identitas Mahasiswa

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

Setelah menyelesaikan codelab dan praktikum pada minggu ke-3 ini, mahasiswa mampu:
1. Menjelaskan konsep navigasi, route, serta perbedaan mendasar antara **Navigator 1.0** (imperatif) dengan **GoRouter** (deklaratif).
2. Menerapkan navigasi *multi-page* dengan `GoRouter`, termasuk penanganan *path parameter* dinamis (`/detail/:id`), nesting route, dan integrasi `ShellRoute`.
3. Menjelaskan urgensi *state management* dalam arsitektur aplikasi Flutter modern serta memahami cara kerja ekosistem **Riverpod** (`ProviderScope`, `Notifier`, `NotifierProvider`, dan `ConsumerWidget`).
4. Menggunakan `AsyncValue` (`AsyncLoading`, `AsyncError`, `AsyncData`) untuk menangani state asinkron secara aman (*compile-safe*) pada antarmuka pengguna.
5. Membangun aplikasi ToDo terintegrasi dengan navigasi, filter status, dan manajemen state berbasis Riverpod.
6. Memverifikasi fungsionalitas dan reaktivitas state melalui unit testing notifier dan widget testing.
7. Menerapkan prinsip *Responsible AI* melalui **AI Challenge**, melakukan verifikasi audit kode, dan mendokumentasikan perbaikan arsitektural.

---

## 📋 Checklist Tugas Mingguan

- [x] **Praktikum 1 — Aplikasi Multi-Page dengan GoRouter:**
  - [x] Mengonfigurasi `GoRouter` dengan rute `/` dan sub-rute `detail/:id`.
  - [x] Menghubungkan router ke aplikasi menggunakan `MaterialApp.router` dan parameter `routerConfig`.
  - [x] Membangun `HomePage` dengan `ListView.builder` dan navigasi via `context.go()`.
  - [x] Membangun `DetailPage` yang membaca argumen dinamis `state.pathParameters['id']`.
- [x] **Praktikum 2 — Aplikasi ToDo dengan Riverpod:**
  - [x] Membungkus root widget aplikasi dengan `ProviderScope`.
  - [x] Mendefinisikan model `Todo` dengan atribut `title`, `done`, serta method `copyWith`.
  - [x] Membuat `TodoListNotifier` (turunan `Notifier<List<Todo>>`) dengan operasi *immutable* (`add`, `toggle`, `remove`).
  - [x] Mengikat state ke UI menggunakan `ConsumerWidget`, `ref.watch()`, dan `ref.read()`.
- [x] **Praktikum 3 — Penanganan State Asinkron dengan `AsyncValue`:**
  - [x] Membuat `StatsNotifier` berbasis `AsyncNotifier` dengan simulasi latensi jaringan dan potensi error.
  - [x] Memetakan ketiga kondisi state menggunakan `asyncValue.when(loading, error, data)`.
  - [x] Mengimplementasikan tombol *retry* deklaratif menggunakan `ref.invalidate()` dan `AsyncValue.guard()`.
- [x] **AI Prompt Challenge & Verification Audit:**
  - [x] Menjalankan prompt pembuatan `StatsPage` dengan AI coding assistant.
  - [x] Melakukan audit menyeluruh berdasarkan *AI Verification Checklist*.
  - [x] Melakukan refactoring kode AI agar mematuhi konvensi modern Riverpod 2.x dan terhubung ke live state aplikasi.
  - [x] Mendokumentasikan prompt, log temuan, dan alasan teknis pada [docs/ai_challenge_log.md](docs/ai_challenge_log.md).
- [x] **Refactoring Challenge:**
  - [x] Memisahkan komponen baris tugas menjadi widget independen `TodoTile` (`lib/widgets/todo_tile.dart`).
  - [x] Mengekstrak logika filter tugas (`all`, `active`, `completed`) menjadi derived `Provider` (`filteredTodoListProvider`).
  - [x] Mengintegrasikan `GoRouter` dengan `NavigationBar` presisten via `ShellRoute` (`MainLayout`).
- [x] **Testing & Verifikasi Kualitas:**
  - [x] Menyusun unit test untuk `TodoListNotifier` dan `filteredTodoListProvider` (`test/todo_notifier_test.dart`).
  - [x] Menyusun unit test untuk `StatsNotifier` (`test/stats_notifier_test.dart`).
  - [x] Menyusun widget test untuk penambahan tugas, toggle, hapus, dan navigasi tab (`test/widget_test.dart`).
  - [x] Memastikan `flutter analyze` bersih (0 issues) dan seluruh pengujian lolos 100% (`flutter test`).

---

## 📚 Rangkuman Teori & Konsep Kunci

### 1. Perbandingan Paradigma Navigasi: Navigator 1.0 vs GoRouter

Flutter secara historis menyediakan mekanisme navigasi imperatif (**Navigator 1.0**) yang mengelola tumpukan layar secara manual (*push/pop stack*). Pendekatan ini memiliki keterbatasan signifikan saat aplikasi berkembang menjadi kompleks (misalnya kebutuhan *deep linking*, URL sinkronisasi di Web, dan *route guards*).

Sebaliknya, **GoRouter** adalah pustaka navigasi deklaratif resmi dari tim Flutter yang memetakan URL langsung ke representasi widget tree.

```
┌──────────────────────────────────────────────────────────────────┐
│                   Perbandingan Alur Navigasi                     │
├─────────────────────────────────┬────────────────────────────────┤
│      Navigator 1.0 (Imperatif)  │      GoRouter (Deklaratif)     │
├─────────────────────────────────┼────────────────────────────────┤
│ Navigator.push(context, route)  │ context.go('/detail/42')       │
│ Stack dikelola manual           │ URL/Path menentukan state stack│
│ Sulit mendukung Deep Link Web   │ Deep Link bawaan dari path URI │
│ Guard login tersebar di UI      │ Redirect guard terpusat        │
└─────────────────────────────────┴────────────────────────────────┘
```

| Fitur / Konsep | Navigator 1.0 | GoRouter (Declarative) |
|---|---|---|
| **Paradigma** | Imperatif (*Stack-based*) | Deklaratif (*URL/Path-based*) |
| **Deep Linking & Web** | Membutuhkan konfigurasi manual yang rumit | Terintegrasi secara *out-of-the-box* |
| **Path Parameters** | Tidak didukung secara native | Didukung langsung lewat `:param` (`state.pathParameters`) |
| **Route Guard & Redirect** | Tersebar di event handler widget | Terpusat pada properti `redirect` di konfigurasi router |
| **Nested / Shell Navigation** | Memerlukan nested Navigator manual | Mendukung `ShellRoute` & `StatefulShellRoute` |

---

### 2. Konsep Arsitektur State Management dengan Riverpod

Menggunakan `setState` lokal menimbulkan masalah *prop drilling* saat state harus dibagikan lintas halaman. **Riverpod** memisahkan state dari lifecycle widget tree sehingga logika aplikasi menjadi mudah diuji (*testable*), aman saat kompilasi (*compile-safe*), dan tidak bergantung pada `BuildContext`.

```
┌─────────────────────────────────────────────────────────────────┐
│                    Arsitektur Flutter Riverpod                  │
│                                                                 │
│                 ┌─────────────────────────────┐                 │
│                 │        ProviderScope        │ (Root Wadah)    │
│                 └──────────────┬──────────────┘                 │
│                                │                                │
│        ┌───────────────────────┴───────────────────────┐        │
│        ▼                                               ▼        │
│ ┌──────────────┐                               ┌──────────────┐ │
│ │ TodoNotifier │ ◄── [Notifier<List<Todo>>]    │StatsNotifier │ │
│ └──────┬───────┘                               └──────┬───────┘ │
│        │ (ref.watch / ref.read)                       │         │
│        ▼                                              ▼         │
│ ┌──────────────┐                               ┌──────────────┐ │
│ │   TodoPage   │ (ConsumerWidget)              │  StatsPage   │ │
│ └──────────────┘                               └──────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

#### Komponen Inti Riverpod:
1. **`ProviderScope`**: Widget root penampung seluruh state provider aplikasi.
2. **`Notifier<T>` & `NotifierProvider`**: Mengelola state sinkron yang dapat dimutasi melalui method eksplisit dengan prinsip *immutability*.
3. **`AsyncNotifier<T>` & `AsyncNotifierProvider`**: Mengelola state asinkron (misalnya pemanggilan API/database).
4. **`ConsumerWidget`**: Pengganti `StatelessWidget` yang menyediakan parameter `WidgetRef ref` di dalam method `build()`.
5. **`ref.watch` vs `ref.read`**:
   - `ref.watch(provider)`: Digunakan di dalam `build()` untuk berlangganan perubahan state dan memicu *rebuild* UI secara reaktif.
   - `ref.read(provider.notifier)`: Digunakan di dalam *event callback* (seperti `onPressed`) untuk memanggil method mutasi tanpa memicu *rebuild* widget pemanggil.

---

### 3. Model State Asinkron: `AsyncValue`

Operasi asinkron umumnya memiliki 3 fase: **Loading**, **Error**, dan **Success (Data)**. Pendekatan konvensional dengan 3 variabel boolean terpisah (`isLoading`, `hasError`, `data`) rentan menimbulkan kondisi *invalid state* (misalnya `isLoading = true` bersamaan dengan `hasError = true`).

`AsyncValue<T>` memodelkan ketiga kondisi tersebut dalam satu tipe *union-like*:

```
               ┌──► AsyncLoading() ──► UI: CircularProgressIndicator
AsyncValue<T> ─┼──► AsyncError(err) ─► UI: Error Card + Retry Button
               └──► AsyncData(value) ─► UI: Render Data List/View
```

Melalui method `.when()`, developer diwajibkan oleh compiler untuk menangani ketiga kemungkinan state, sehingga mencegah *bug* layar kosong atau *unhandled exception*.

---

## 🛠️ Struktur Proyek & Implementasi

```
03-week-3-navigation-state-management/
├── docs/
│   └── ai_challenge_log.md           # Log prompt, checklist audit, dan refactoring AI
├── lib/
│   ├── main.dart                     # ProviderScope, GoRouter, MaterialApp.router
│   ├── models/
│   │   ├── todo.dart                 # Model Todo immutable dengan copyWith
│   │   └── stats.dart                # Model TaskStats untuk metrik dashboard
│   ├── pages/
│   │   ├── detail_page.dart          # Halaman detail penerima path parameter /detail/:id
│   │   ├── home_page.dart            # Demo multi-page GoRouter (Praktikum 1)
│   │   ├── stats_page.dart           # Halaman statistik dengan AsyncValue (AI Challenge)
│   │   └── todo_page.dart            # Halaman utama ToDo dengan ConsumerWidget & filter
│   ├── providers/
│   │   ├── stats_provider.dart       # AsyncNotifierProvider untuk simulasi API data
│   │   ├── todo_filter_provider.dart # Notifier filter & derived filteredTodoListProvider
│   │   └── todo_provider.dart        # NotifierProvider untuk state ToDo list
│   └── widgets/
│       ├── main_layout.dart          # Shell layout dengan persistent NavigationBar
│       └── todo_tile.dart            # Komponen modular kartu item tugas
├── test/
│   ├── stats_notifier_test.dart      # Unit test untuk AsyncNotifier statistik
│   ├── todo_notifier_test.dart       # Unit test untuk ToDo list & derived filter
│   └── widget_test.dart              # Widget test integrasi ToDo, toggle, & navigasi
├── analysis_options.yaml             # Aturan linting ketat Flutter
└── pubspec.yaml                      # Konfigurasi dependensi (go_router, flutter_riverpod)
```

---

## ⚡ Detail Refactoring Challenge

Sesuai instruksi jobsheet, refactoring berikut telah diterapkan:

1. **Pemisahan `TodoTile` (`lib/widgets/todo_tile.dart`):**
   - Menghilangkan kode *boilerplate* dari `TodoPage`.
   - Mengisolasi dekorasi coret (*strikethrough*), animasi checkbox, dan aksi hapus agar mudah diuji secara independen.
2. **Ekstraksi Derived Provider Filter (`filteredTodoListProvider`):**
   - Logika pemfilteran (`Semua`, `Aktif`, `Selesai`) dipindahkan keluar dari widget ke provider turunan yang secara otomatis mengamati `todoListProvider` dan `todoFilterProvider`.
3. **Integrasi GoRouter dengan `NavigationBar` (`MainLayout`):**
   - Menggunakan `ShellRoute` pada konfigurasi router untuk menjaga *bottom bar* tetap presisten saat berpindah rute antara `/` (Daftar Tugas) dan `/stats` (Statistik).

---

## 🧪 Hasil Pengujian & Verifikasi

### 1. Analisis Statis (`flutter analyze`)
```bash
$ flutter analyze
Analyzing 03-week-3-navigation-state-management...
No issues found! (ran in 1.2s)
```

### 2. Eksekusi Seluruh Pengujian Otomatis (`flutter test`)
```bash
$ flutter test
00:00 +0: loading test/stats_notifier_test.dart
00:00 +0: test/todo_notifier_test.dart: TodoListNotifier Initial state should be an empty list
00:00 +1: test/stats_notifier_test.dart: StatsNotifier computes correct statistics from TodoList state
00:00 +2: test/stats_notifier_test.dart: StatsNotifier computes correct statistics from TodoList state
00:00 +3: test/stats_notifier_test.dart: StatsNotifier computes correct statistics from TodoList state
00:00 +4: test/stats_notifier_test.dart: StatsNotifier computes correct statistics from TodoList state
00:00 +5: test/stats_notifier_test.dart: StatsNotifier computes correct statistics from TodoList state
00:01 +6: test/stats_notifier_test.dart: StatsNotifier computes correct statistics from TodoList state
00:01 +7: test/stats_notifier_test.dart: StatsNotifier computes correct statistics from TodoList state
00:02 +8: test/widget_test.dart: berpindah tab antara Daftar Tugas dan Statistik melalui NavigationBar
00:02 +9: test/stats_notifier_test.dart: StatsNotifier handles error when forced to fail
00:04 +10: All tests passed!
```

---

## 💡 Jawaban Pertanyaan Refleksi

### 1. Kapan `setState` masih cukup, dan kapan state harus naik ke Riverpod?
- **`setState` Masih Cukup:** Saat *state* bersifat **lokal dan efemeral** yang hanya memengaruhi satu widget itu sendiri tanpa perlu diketahui oleh widget lain. Contohnya: teks sementara pada `TextEditingController`, animasi ekspansi kartu lokal, atau status fokus input form.
- **State Harus Naik ke Riverpod:** Saat *state* bersifat **global / lintas halaman** (misal: data keranjang belanja, status autentikasi, daftar ToDo yang ditampilkan di halaman tugas dan direkap di halaman statistik), atau ketika logika manipulasi state perlu diuji melalui *unit testing* tanpa harus merender *widget tree*.

### 2. Apa perbedaan `context.go` dan `context.push`, dan kapan masing-masing tepat digunakan?
- **`context.go(path)`**: Mengganti *location* dan menyesuaikan susunan tumpukan (*navigation stack*) sesuai hierarki deklaratif rute. Sangat tepat digunakan untuk navigasi tingkat utama (seperti *tab switching* di `NavigationBar`, alur setelah login/logout, atau pengalihan rute dasar).
- **`context.push(path)`**: Menumpuk (*push*) rute baru secara eksplisit di atas *stack* aktif saat ini tanpa mengubah hierarki induknya. Tepat digunakan untuk membuka halaman detail, modal flow, atau form penambahan data di mana pengguna diharapkan menekan tombol *Back* untuk kembali ke halaman asal.

### 3. Bagaimana `AsyncValue` mencegah bug dibanding tiga boolean terpisah?
Penggunaan tiga boolean terpisah (`isLoading`, `hasError`, `hasData`) memiliki kelemahan mendasar:
- **Kondisi Invalid/Inkonsisten:** Memungkinkan terjadinya kondisi logika rancu, seperti `isLoading = true` bersamaan dengan `hasError = true` dan `data != null`.
- **Lupa Menangani Error:** Developer rawan lupa menulis blok penanganan error sehingga saat API gagal, UI tetap menampilkan layar putih atau spinner tanpa akhir.
- **Pencegahan via `AsyncValue`:** `AsyncValue` memodelkan state sebagai tipe eksklusif (*tagged union*). Method `.when()` memaksa developer menangani ketiga cabang (`loading`, `error`, `data`) secara eksplisit di waktu kompilasi (*compile-time safety*). Selain itu, utilitas `AsyncValue.guard()` secara otomatis menangkap exception tanpa perlu blok `try-catch` yang berulang.

### 4. Bagian mana dari hasil AI yang Anda perbaiki, dan mengapa?
Berdasarkan log audit pada [docs/ai_challenge_log.md](docs/ai_challenge_log.md), bagian yang diperbaiki meliputi:
1. **Penyambungan ke Live State:** Kode awal AI menggunakan data statistik tiruan yang di-*hardcode*. Kode diperbaiki agar `StatsNotifier` membaca `ref.read(todoListProvider)` secara dinamis dari daftar ToDo aplikasi.
2. **Penggunaan `ref.invalidate` Idiomatis:** AI membuat method `retry()` manual yang menduplikasi kode pemanggilan data. Diperbaiki dengan memanfaatkan fitur `ref.invalidate(statsProvider)` bawaan Riverpod.
3. **Penyempurnaan Design System Material 3:** Meningkatkan tampilan kartu analitik dengan visual hierarchy (`LinearProgressIndicator`, container warna adaptif, dan tombol uji simulasi error untuk asesmen).
4. **Unit Testing Deterministik:** Menambahkan kontrol simulasi error eksplisit (`enableRandomFailures = false`) agar unit test berjalan cepat, konsisten, dan bebas dari keacakan (*flaky tests*).

---

## 🚀 Cara Menjalankan Proyek

### 1. Pemasangan Dependensi
```bash
cd 03-week-3-navigation-state-management
flutter pub get
```

### 2. Menjalankan Analisis Lint
```bash
flutter analyze
```

### 3. Menjalankan Seluruh Automated Test
```bash
flutter test
```

### 4. Menjalankan Aplikasi di Perangkat / Emulator
```bash
flutter run
```

---

## 📑 Referensi Pendukung
- [Flutter Official Navigation & Routing Guide](https://docs.flutter.dev/ui/navigation)
- [GoRouter Package Documentation](https://pub.dev/packages/go_router)
- [Riverpod 2.x Official Documentation](https://riverpod.dev/docs/introduction/getting_started)
- [Riverpod AsyncNotifier & AsyncValue Guide](https://riverpod.dev/docs/concepts/async_notifiers)
- [Codelab Week 3 JTI Polinema](https://jti-polinema.github.io/flutter-codelab/03-minggu-3-navigation-state-management/)
