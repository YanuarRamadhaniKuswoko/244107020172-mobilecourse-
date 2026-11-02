// test/search_filter_test.dart
//
// Praktikum 2 – Verifikasi generate dan verify search
// Jobsheet Minggu 9 mewajibkan minimal 1 test sukses + 1 test gagal untuk search.
//
// Bukti halusinasi AI yang ditemukan:
//   AI awalnya mengusulkan `notes.searchFuzzy(query)` — method ini tidak ada
//   di List<Note>. Dibuktikan: tidak ada autocomplete untuk `searchFuzzy`
//   dan grep di pub.dev/sqflite tidak menemukan method tersebut.
//   Keputusan: TOLAK. Ganti dengan fungsi murni `filterNotes` di domain.

import 'package:flutter_test/flutter_test.dart';
import 'package:notes_search_ai/features/notes/domain/entities/note.dart';
import 'package:notes_search_ai/features/notes/domain/usecases/search_notes.dart';

// ── Fixture data ──────────────────────────────────────────────────────────────
final _now = DateTime(2026, 11, 1);

List<Note> _fixture() => [
  Note(id: 1, title: 'Belanja Mingguan', updatedAt: _now),
  Note(id: 2, title: 'Catatan Belanja Bulanan', updatedAt: _now),
  Note(id: 3, title: 'Meeting Sprint Review', updatedAt: _now),
  Note(id: 4, title: 'Flutter Tips', updatedAt: _now),
  Note(id: 5, title: 'BELANJA besar', updatedAt: _now), // all caps
];

// ── Unit tests untuk filterNotes (fungsi domain murni) ───────────────────────
void main() {
  group('filterNotes (pure function)', () {
    // ✅ Test sukses 1: query kosong kembalikan semua catatan
    test('query kosong mengembalikan semua catatan', () {
      final result = filterNotes(_fixture(), '');
      expect(result, hasLength(5));
    });

    // ✅ Test sukses 2: cocok case-insensitive
    test('filter abaikan huruf besar/kecil', () {
      final result = filterNotes(_fixture(), 'belanja');
      // Harus cocok: Belanja Mingguan, Catatan Belanja Bulanan, BELANJA besar
      expect(result, hasLength(3));
      for (final note in result) {
        expect(note.title.toLowerCase(), contains('belanja'));
      }
    });

    // ✅ Test sukses 3: query dengan spasi leading/trailing
    test('query dengan spasi di tepi di-trim', () {
      final result = filterNotes(_fixture(), '  flutter  ');
      expect(result, hasLength(1));
      expect(result.first.title, equals('Flutter Tips'));
    });

    // ✅ Test sukses 4: pencarian sebagian kata
    test('pencarian sebagian kata (substring) bekerja', () {
      final result = filterNotes(_fixture(), 'sprint');
      expect(result, hasLength(1));
      expect(result.first.title, contains('Sprint'));
    });

    // ❌ Test gagal: query tidak cocok kembalikan kosong
    test('query tak cocok kembalikan daftar kosong', () {
      final result = filterNotes(_fixture(), 'zzz-tak-ada-9999');
      expect(result, isEmpty);
    });

    // ❌ Test gagal 2: query hanya spasi = anggap kosong, kembalikan semua
    test('query hanya spasi dianggap kosong', () {
      final result = filterNotes(_fixture(), '   ');
      expect(result, hasLength(5));
    });

    // Membuktikan bug halusinasi AI: AI menyebut hasil selalu diurut
    // padahal filterNotes tidak menjamin urutan tertentu.
    // Verifikasi: urutan harus mengikuti urutan list asli.
    test('urutan hasil mengikuti list asal (tidak di-sort ulang)', () {
      final result = filterNotes(_fixture(), 'belanja');
      // id urutan di list asli: 1, 2, 5
      expect(result.map((n) => n.id).toList(), [1, 2, 5]);
    });
  });

  group('SearchNotes use case (wrapper class)', () {
    const searchNotes = SearchNotes();

    test('delegasi ke filterNotes dengan benar', () {
      final notes = _fixture();
      expect(searchNotes(notes, 'meeting'), hasLength(1));
      expect(searchNotes(notes, ''), hasLength(5));
      expect(searchNotes(notes, 'tidak ada'), isEmpty);
    });
  });
}
