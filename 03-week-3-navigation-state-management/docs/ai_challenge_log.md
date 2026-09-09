# AI Challenge Log & Verification Audit - Minggu 03

**Mata Kuliah:** Pemrograman Mobile  
**Semester:** 5  
**Topik:** Navigation & State Management (GoRouter & Riverpod)  
**Mahasiswa:** Yanuar Ramadhani Kuswoko (NIM: 244107020176 / Kelas: TI-2D / Absen: 25)  

---

## 1. AI Prompt yang Digunakan

```text
Buatkan halaman Flutter bernama StatsPage menggunakan flutter_riverpod.
Requirements:
- ConsumerWidget dengan satu AsyncNotifierProvider yang mensimulasikan
  pengambilan data statistik (delay 2 detik, kadang gagal 30%).
- UI harus menangani loading (spinner), error (pesan + tombol retry),
  dan success (ListView 3 item).
- Berikan unit test untuk notifier-nya.
Jelaskan setiap bagian kode dalam komentar.
```

---

## 2. Output Awal Kode dari AI (Generasi Awal)

```dart
// stats_page.dart (Initial Raw Generation)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';

// Data model
class StatsData {
  final int total;
  final int completed;
  final int pending;
  StatsData(this.total, this.completed, this.pending);
}

// AsyncNotifier
class StatsNotifier extends AsyncNotifier<StatsData> {
  @override
  Future<StatsData> build() async {
    await Future.delayed(const Duration(seconds: 2));
    if (Random().nextDouble() < 0.3) {
      throw Exception('Network error');
    }
    return StatsData(10, 6, 4);
  }

  Future<void> retry() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await Future.delayed(const Duration(seconds: 2));
      return StatsData(10, 6, 4);
    });
  }
}

final statsProvider = AsyncNotifierProvider<StatsNotifier, StatsData>(StatsNotifier.new);

class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Stats')),
      body: stats.when(
        data: (data) => ListView(
          children: [
            ListTile(title: Text('Total: ${data.total}')),
            ListTile(title: Text('Completed: ${data.completed}')),
            ListTile(title: Text('Pending: ${data.pending}')),
          ],
        ),
        error: (err, stack) => Center(
          child: Column(
            children: [
              Text('$err'),
              ElevatedButton(
                onPressed: () => ref.read(statsProvider.notifier).retry(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
```

---

## 3. Audit AI Verification Checklist

| Kriteria Audit | Status | Temuan / Catatan Evaluasi |
|---|:---:|---|
| **1. Immutability State** | ✅ Lolos | Objek `StatsData` / `TaskStats` bersifat immutable. State di-*assign* melalui `AsyncValue.guard` tanpa memutasi objek secara langsung. |
| **2. Penggunaan `ref.watch` vs `ref.read`** | ✅ Lolos | `ref.watch` ditempatkan di dalam method `build()`, sedangkan operasi pemicu aksi di *event callback* menggunakan `ref.read` / `ref.invalidate`. |
| **3. Kelengkapan Penanganan State `AsyncValue`** | ✅ Lolos | Ketiga state (`loading`, `error`, dan `data`) ditangani secara eksplisit menggunakan pattern matching `.when()`. |
| **4. Deklarasi Provider Eksplisit & Tidak Duplikat** | ✅ Lolos | Tipe generik dinyatakan secara eksplisit: `AsyncNotifierProvider<StatsNotifier, TaskStats>`. |
| **5. Bebas dari API Riverpod Usang (Anti-pattern)** | ⚠️ Diperbaiki | Menghindari `StateProvider` & `StateNotifierProvider` usang, memastikan penggunaan modern `AsyncNotifier` dan `ref.invalidate` untuk deklaratif reset. |
| **6. Lolos Lint & Testing (`flutter analyze` & `test`)** | ✅ Lolos | Kode telah di-refactor, 0 issue pada analyzer, dan unit test lolos 100%. |

---

## 4. Perbaikan & Refactoring yang Dilakukan

1. **Integrasi Live Data dengan State Aplikasi (`todoListProvider`):**
   - *Sebelum:* AI membuat hardcoded data `StatsData(10, 6, 4)` yang terisolasi dari daftar ToDo.
   - *Perbaikan:* `StatsNotifier` membaca `ref.read(todoListProvider)` secara dinamis sehingga statistik mencerminkan jumlah tugas nyata dari aplikasi.

2. **Penyempurnaan Mekanisme Refresh (`ref.invalidate`):**
   - *Sebelum:* Dibuat method manual `retry()` yang menduplikasi logika pengambilan data.
   - *Perbaikan:* Menggunakan `ref.invalidate(statsProvider)` dan `AsyncValue.guard()` yang lebih idiomatis di Riverpod 2.x untuk menjalankan ulang lifecycle `build()`.

3. **Peningkatan UX & Design System Material 3:**
   - *Sebelum:* UI dasar dengan `ElevatedButton` dan `ListTile` polos tanpa visual hierarchy.
   - *Perbaikan:* Ditambahkan kartu progres penyelesaian (`LinearProgressIndicator`), palet warna bertema Material 3 (`primaryContainer`, `errorContainer`), serta tombol simulasi error eksplisit untuk kemudahan asesmen dosen.

4. **Pengujian Unit Otomatis yang Deterministik:**
   - *Sebelum:* AI menghasilkan test yang masih memiliki delay non-deterministik acak.
   - *Perbaikan:* Ditambahkan flag `enableRandomFailures` dan `forceError` agar unit test dapat memverifikasi kalkulasi data maupun penanganan error secara terisolasi dan konsisten.

---

## 5. Kesimpulan Teknis

Penerapan AI sebagai *co-developer* mempercepat pembuatan *boilerplate code* awal. Namun, intervensi rekayasa perangkat lunak tetap krusial untuk memastikan integrasi data yang kohesif antar-provider, kepatuhan arsitektur Riverpod 2.x modern, serta keterujian kode (*testability*) yang handal.
