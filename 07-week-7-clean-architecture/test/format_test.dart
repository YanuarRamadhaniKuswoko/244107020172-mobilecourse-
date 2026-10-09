import 'package:clean_architecture_notes/core/format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Core Formatting Pure Helpers', () {
    test('formatDateTime produces correct zero-padded string', () {
      final dt = DateTime(2026, 9, 27, 8, 5, 9);
      final formatted = formatDateTime(dt);
      expect(formatted, '27/09/2026 08:05:09');
    });

    test('formatDateShort formats date only', () {
      final dt = DateTime(2026, 12, 5, 23, 10);
      expect(formatDateShort(dt), '05/12/2026');
    });

    test('formatDirtyStatus differentiates dirty and clean state', () {
      expect(formatDirtyStatus(true), 'Belum Sinkron (Offline)');
      expect(formatDirtyStatus(false), 'Tersinkron');
    });

    test('calculateWordCount counts words correctly', () {
      expect(calculateWordCount(''), 0);
      expect(calculateWordCount('   '), 0);
      expect(calculateWordCount('Clean Architecture Flutter'), 3);
      expect(calculateWordCount('  Satu   dua  tiga  empat '), 4);
    });
  });
}

