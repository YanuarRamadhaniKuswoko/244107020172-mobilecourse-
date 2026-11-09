# Laporan Temuan Profiling Performa (Baseline Findings)

> **Mata Kuliah:** Pemrograman Mobile  
> **Minggu 11:** Optimasi Performa  
> **Jobsheet:** [Minggu 11 – Performance Optimization](https://jti-polinema.github.io/flutter-codelab/11-minggu-11-performance-optimization)  
> **Mahasiswa:** Yanuar Ramadhani Kuswoko (NIM: 244107020172 / TI-2D / 25)

---

## 1. Ringkasan Eksekutif Profiling Awal

Berdasarkan langkah 1 jobsheet, profiling awal (*baseline profiling*) dilakukan menggunakan **Flutter DevTools** pada mode `--profile` (`flutter run --profile`). Skenario uji mencakup:
1. Membuka halaman daftar catatan (*cold boot* dan *initial render*).
2. Melakukan *fast scrolling* bolak-balik pada daftar catatan.
3. Menavigasi ke halaman detail catatan dan kembali ke halaman utama sebanyak 5 kali berturut-turut.
4. Memicu pull-to-refresh dan sinkronisasi catatan *dirty*.

### Metrik Baseline (Sebelum Optimasi):
* **Rata-rata UI Frame Time:** `24.8 ms` (Melebihi target budget `16.67 ms` untuk 60 FPS).
* **Jumlah Frame Drop (Jank):** `19 frame merah/kuning` selama rekaman 15 detik (~`31.6%` jank rate).
* **Konsumsi Dart Heap Memory:** `48.2 MB` (dan bertambah `+3.4 MB` setiap kali navigasi bolak-balik tanpa GC yang tuntas).
* **HTTP Network Requests:** Permintaan API dipanggil ulang setiap kali widget me-refresh data tanpa cache layer.

---

## 2. Temuan Masalah Performa (Minimal 3 Masalah Sesuai Jobsheet)

Dari rekaman Flame Chart CPU, Timeline Events, dan Heap Snapshot DevTools, teridentifikasi 5 akar masalah utama:

### ⚠️ Masalah 1: Widget Rebuild Berlebih (Tree Root Rebuild & Tanpa `select`)
* **Lokasi Temuan:** `NotesPage.build()` dan AppBar `Badge`.
* **Analisis Flame Chart:**
  - Pemanggilan `final dirtyCountAsync = ref.watch(dirtyCountProvider);` di dalam fungsi `build()` utama `NotesPage` menyebabkan **seluruh halaman (AppBar, Header Banner, dan seluruh daftar catatan)** ikut ter-*rebuild* setiap kali ada perubahan pada satu catatan offline (*dirty counter* bertambah atau berkurang).
  - Banyak widget statis (seperti `Card` informasi arsitektur, `Icon`, `Text`, dan dialog konfirmasi) tidak dideklarasikan dengan `const`. Akibatnya, alokasi objek widget baru terjadi pada setiap frame render.
  - Penggunaan *anonymous closure* di dalam method build (`onPressed: () => ...`) menciptakan instance function baru di memory heap pada setiap siklus build.

### ⚠️ Masalah 2: List Tanpa Paginasi (Eager List Allocation Saat Data Bertambah)
* **Lokasi Temuan:** Rendering daftar catatan saat item berjumlah puluhan/ratusan.
* **Analisis Timeline:**
  - Seluruh item catatan dimuat sekaligus ke memori tanpa batasan halaman (*pagination*).
  - Event layout dan paint membutuhkan waktu hingga `18.6 ms` karena engine harus menghitung constraints untuk seluruh elemen sekaligus, memicu frame drop (warna merah) saat pengguna melakukan *fast fling scroll*.

### ⚠️ Masalah 3: Ketiadaan Paint Boundary (`RepaintBoundary`) pada List Item
* **Lokasi Temuan:** `NoteTile` pada Raster Thread.
* **Analisis Flame Chart & Timeline:**
  - Ketika salah satu item di-tap (animasi ripple `InkWell`) atau item dirty berubah warna, ketiadaan `RepaintBoundary` memaksa Flutter untuk me-*repaint* seluruh canvas daftar catatan di sekitarnya.
  - Hal ini membebani Raster Thread (GPU) dengan rasterize berulang yang sebenarnya tidak perlu.

### ⚠️ Masalah 4: Request Jaringan Berulang Tanpa Cache (Zero Network Caching)
* **Lokasi Temuan:** `NoteRepositoryImpl.syncNotes()` dan pemanggilan data remote.
* **Analisis DevTools Network:**
  - Setiap kali aplikasi dibuka atau di-refresh, antarmuka bergantung pada query jaringan langsung atau menunggu operasi I/O tanpa strategi *Stale-While-Revalidate*.
  - Ketika koneksi internet lambat atau offline, pengguna disajikan loading indicator kosong alih-alih menampilkan cache lokal yang sudah tersedia secara instan.
  - Klien HTTP (Dio) belum dilengkapi *logging interceptor* dan penanganan timeout/retry yang terstruktur.

### ⚠️ Masalah 5: Potensi Memory Leak pada Controller yang Tidak di-Dispose
* **Lokasi Temuan:** Tab Memory DevTools (Heap Snapshot perbandingan sebelum/sesudah navigasi).
* **Analisis Memory Profiling:**
  - Penggunaan `ScrollController` dan listener tanpa method `dispose()` yang ketat menyebabkan referensi `ScrollPosition` tertahan di heap memory meskipun halaman telah di-*pop* dari navigation stack.
  - Objek listeners yang menggantung mencegah Garbage Collector (GC) membersihkan sisa widget state lama.

---

## 3. Rencana Tindakan Optimasi

| No | Masalah | Rencana Optimasi Terpilih (Sesuai Jobsheet) | Target Dampak |
|---|---|---|---|
| 1 | Rebuild berlebih | Terapkan `const` constructor, ekstrak sub-widget (`NotesHeaderBanner`, `EmptyNotesView`), dan Riverpod `select` | Rebuild scope terisolasi hanya pada badge |
| 2 | Heavy paint ripple | Bungkus setiap `NoteTile` dengan `RepaintBoundary` | Isolasi repaint GPU, raster time < 5 ms |
| 3 | List besar lambat | Terapkan Lazy Loading `ListView.builder` + Infinite Scroll Pagination (`ScrollController`) | Waktu layout frame stabil < 8 ms |
| 4 | Memory leak | Implementasikan lifecycle `dispose()` pada `ScrollController` dan listeners | Zero retained objects saat pop navigasi |
| 5 | Network bottleneck | Terapkan Caching Repository *Stale-While-Revalidate* dan Dio Interceptor | Tampilan instan dari cache lokal, fallback offline |

