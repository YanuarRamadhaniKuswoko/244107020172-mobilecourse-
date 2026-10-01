# AI Challenge Log & Storage Comparison Audit — Minggu 05

**Mata Kuliah:** Pemrograman Mobile  
**Topik:** Local Storage (SharedPreferences, Hive, SQLite/sqflite, Drift) & Offline-First Architecture  
**Mahasiswa:** Yanuar Ramadhani Kuswoko (NIM: 244107020176 / Kelas: TI-2D / Absen: 25)  

---

## 1. AI Prompt Challenge

Sesuai instruksi jobsheet Codelab Minggu 5, prompt berikut diajukan kepada AI Coding Assistant:

```text
Aplikasi Flutter Offline Notes: CRUD catatan + preferensi tema.
Bandingkan SharedPreferences, Hive, sqflite (SQLite), dan Drift
untuk dua kebutuhan ini. Requirements:
- Kriteria: kompleksitas query, kebutuhan relasi, reaktivitas (stream),
  type-safety, ukuran boilerplate, dan kemudahan testing.
- Beri rekomendasi final: mana untuk preferensi, mana untuk catatan,
  beserta alasannya dalam 1 tabel.
- Tunjukkan skema tabel/kotak untuk 1000+ catatan.
Jelaskan trade-off setiap pilihan.
```

---

## 2. Output Awal dari AI (*Raw AI Response*)

Berikut adalah rekaman respons awal yang dihasilkan oleh AI:

````markdown
Berikut adalah perbandingan storage untuk aplikasi Flutter Offline Notes:

### Tabel Perbandingan Storage
| Storage | Kompleksitas Query | Relasi | Reaktivitas | Type-Safety | Boilerplate | Kemudahan Test |
|---|---|---|---|---|---|---|
| **SharedPreferences** | Sangat Rendah (Key-Value saja) | Tidak ada | Tidak ada bawaan | Rendah (hanya tipe primitif) | Sangat Rendah | Sangat Mudah (Mock SharedPreferences) |
| **Hive** | Rendah - Sedang (Bisa filtering via box) | Tidak ada bawaan | Tinggi (Watch Box/ValueListenable) | Tinggi (dengan TypeAdapter) | Rendah - Sedang (`build_runner`) | Mudah (Hive in-memory) |
| **sqflite (SQLite)** | Tinggi (Full SQL query, JOIN, Indexing) | Penuh (Foreign Key, Relasional) | Manual (Perlu dibungkus StreamController/Riverpod) | Sedang (Map-based, manual mapping) | Sedang (SQL string DDL) | Sedang (Injeksi Fake Repo / SQLite ffi) |
| **Drift (Moor)** | Sangat Tinggi (Fluent API & Raw SQL) | Penuh (Relasi formal & type-safe) | Sangat Tinggi (Built-in Stream query) | Sangat Tinggi (Compile-time verified) | Tinggi (`build_runner` + codegen) | Sangat Mudah (in-memory Drift database) |

### Rekomendasi Final
| Kebutuhan | Rekomendasi | Alasan Teknis |
|---|---|---|
| **Preferensi Tema** | `SharedPreferences` | Hanya menyimpan nilai boolean `dark_mode` dan string kecil `last_opened_at`. Sangat ringan tanpa overhead database. |
| **CRUD Catatan** | `sqflite` (atau `Drift`) | Data catatan berpotensi tumbuh 1000+ baris, memerlukan pengurutan `updated_at DESC`, query filter `dirty = 1`, dan indeks cepat. |

### Contoh Skema 1000+ Catatan

1. **SQLite / sqflite (DDL):**
```sql
CREATE TABLE notes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  body TEXT NOT NULL DEFAULT '',
  updated_at TEXT NOT NULL,
  dirty INTEGER NOT NULL DEFAULT 0
);
CREATE INDEX idx_notes_updated_at ON notes(updated_at DESC);
CREATE INDEX idx_notes_dirty ON notes(dirty);
```

2. **Hive (Box / Adapter):**
```dart
@HiveType(typeId: 0)
class NoteHive extends HiveObject {
  @HiveField(0) int? id;
  @HiveField(1) String title;
  @HiveField(2) String body;
  @HiveField(3) DateTime updatedAt;
  @HiveField(4) bool dirty;
}
```

3. **Drift (Dart Table Definition):**
```dart
class Notes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get body => text().withDefault(const Constant(''))();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get dirty => boolean().withDefault(const Constant(false))();
}
```
````

---

## 3. AI Verification Checklist & Audit Kritis

Berdasarkan *AI Verification Checklist* pada modul jobsheet, dilakukan telaah kritis terhadap rekomendasi AI:

| Kriteria Verifikasi | Evaluasi | Temuan & Keputusan Mahasiswa |
|---|:---:|---|
| **1. Penempatan Catatan di Storage yang Tepat** | ✅ Ditolak untuk SharedPreferences | AI merekomendasikan penolakan `SharedPreferences` untuk koleksi catatan. Menyimpan seluruh catatan sebagai JSON string tunggal di SharedPreferences adalah *anti-pattern* (setiap mutasi 1 baris mengharuskan serialisasi ulang seluruh array, tidak bisa di-indeks, boros memori). |
| **2. Dukungan Antrean Sync (*Dirty Flag* & *Timestamp*)** | ✅ Terverifikasi | Skema SQL dan model yang diusulkan telah memuat kolom `dirty` (0/1) dan `updated_at` bertipe ISO8601 string / DateTime, esensial untuk mekanisme antrean sinkronisasi *offline-first*. |
| **3. Validitas Klaim "Real-Time / Reaktif"** | ⚠️ Dikoreksi | AI mengklaim Hive dan Drift memiliki *real-time stream*, namun untuk `sqflite` reaktivitas harus dibangun di lapisan arsitektur (menggunakan Riverpod `AsyncNotifier` / `ref.invalidate`). Hal ini diverifikasi benar dan diterapkan pada `notesProvider`. |
| **4. Estimasi Boilerplate & Instalasi** | ⚠️ Dikoreksi | Drift membutuhkan dependensi berat (`drift`, `sqlite3_flutter_libs`, `drift_dev`, `build_runner`) dan proses *code generation* yang memakan waktu build. Sedangkan `sqflite` hanya membutuhkan `sqflite` dan `path` tanpa *code generator*. |
| **5. Keputusan Final Mahasiswa** | ✅ Ditetapkan | Memilih kombinasi **`SharedPreferences`** (untuk preferensi key-value) + **`sqflite (SQLite)`** (untuk koleksi catatan dan cache API) karena memberikan keseimbangan optimal antara kontrol SQL, performa query, efisiensi bundle, dan kesederhanaan *testing*. |

---

## 4. Analisis Mendalam: Perbandingan 4 Solusi Storage

```
                           ┌────────────────────────────────────────────────┐
                           │            Kebutuhan Local Storage            │
                           └───────────────────────┬────────────────────────┘
                                                   │
                   ┌───────────────────────────────┴───────────────────────────────┐
                   ▼                                                               ▼
        [ Key-Value Primitif ]                                          [ Koleksi & Terstruktur ]
       • Tema (dark_mode)                                              • CRUD Catatan (1000+ baris)
       • Waktu buka (last_opened)                                      • Antrean Sinkronisasi (dirty)
                   │                                                   • Cache REST API (cached_posts)
                   ▼                                                               │
        ┌─────────────────────┐                                                    ▼
        │  SharedPreferences  │                                     ┌─────────────────────────────┐
        └─────────────────────┘                                     │       SQLite (sqflite)      │
                                                                    └─────────────────────────────┘
```

### 1. SharedPreferences (Key-Value)
- **Kelebihan:** Sangat ringan, menggunakan API bawaan platform (Android `SharedPreferences` / iOS `NSUserDefaults`), tanpa skema database.
- **Kelemahan:** Hanya untuk data primitif (`bool`, `int`, `double`, `String`, `List<String>`). Tidak mendukung query SQL, sorting, maupun indexing.
- **Tepat untuk:** Preferensi UI (tema, bahasa, token sesi, timestamp buka).

### 2. Hive (NoSQL Key-Value / Object Box)
- **Kelebihan:** Murni Dart (sangat cepat), mendukung objek terstruktur dengan TypeAdapter, API sederhana mirip Map.
- **Kelemahan:** Bukan database relasional. Untuk query kompleks (misal filter catatan dirty + sort berdasarkan tanggal) harus memuat seluruh box ke RAM (*in-memory filtering*). Kurang ideal untuk relasi tabel dan join.
- **Tepat untuk:** Cache respons API sederhana, offline catalog tanpa relasi kompleks.

### 3. SQLite via `sqflite` (Relational SQL Engine)
- **Kelebihan:** Mesin SQL C-level standar industri, mendukung transaksi ACID, query kompleks, agregasi (`COUNT(*) WHERE dirty = 1`), indexing B-Tree, dan pagination (`LIMIT/OFFSET`) tanpa memuat seluruh data ke RAM.
- **Kelemahan:** Membutuhkan penulisan DDL query string manual dan mapping `fromMap`/`toMap`.
- **Tepat untuk:** Aplikasi produktivitas, *offline-first notes*, transaksi keuangan, dan cache relasional terstruktur.

### 4. Drift / Moor (Type-Safe Reactive SQLite)
- **Kelebihan:** Seluruh tabel dan query diverifikasi saat compile-time (tidak ada typo nama kolom), mendukung auto-generated Stream query.
- **Kelemahan:** Overhead dependensi besar, membutuhkan `build_runner` untuk *code generation*, kurva belajar tinggi.
- **Tepat untuk:** Aplikasi enterprise berskala besar dengan puluhan tabel dan query relasi rumit.

---

## 5. Keputusan Final & Justifikasi Arsitektural

### Mengapa SharedPreferences + SQLite (`sqflite`) Dipilih?

1. **Pemisahan Tanggung Jawab (*Separation of Concerns*):**
   - Preferensi user (`dark_mode`, `last_opened_at`) bersifat atomik dan non-relasional, sehingga tepat diletakkan di `SharedPreferences` tanpa membebani database.
   - Catatan memiliki siklus hidup mandiri dengan status sinkronisasi (`dirty`), timestamp modifikasi (`updated_at`), serta berpotensi berkembang hingga ribuan data. SQLite menyediakan pengurutan instan (`ORDER BY updated_at DESC`) dan query agregasi (`SELECT COUNT(*) FROM notes WHERE dirty = 1`) secara efisien.

2. **Kesiapan Offline-First:**
   - Melalui SQLite, kita juga dapat membuat tabel terpisah `cached_posts` untuk menyimpan cache respons REST API (`GET /posts`). Pola *Cache-First Read* dapat dijalankan dengan membaca SQLite terlebih dahulu sebelum melakukan network fetch di background.

3. **Kemudahan Testing & Isolasi:**
   - `NoteRepository` dirancang dengan konstruktor `openDb` yang *injectable*, memungkinkan pengujian unit di `test/note_test.dart` menggunakan `FakeNoteRepository` tanpa menyentuh SQLite sungguhan.
