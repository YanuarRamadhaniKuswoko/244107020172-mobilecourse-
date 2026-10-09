import 'package:clean_architecture_notes/features/notes/data/models/note_model.dart';
import 'package:clean_architecture_notes/features/notes/domain/entities/note.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NoteModel Data Layer Mapping', () {
    test('fromMap creates valid NoteModel with fallback defaults', () {
      final map = <String, Object?>{
        'id': 1,
        'title': 'Test Catatan',
        'body': 'Isi catatan',
        'updated_at': '2026-09-27T10:00:00.000',
        'dirty': 1,
      };

      final model = NoteModel.fromMap(map);

      expect(model.id, 1);
      expect(model.title, 'Test Catatan');
      expect(model.body, 'Isi catatan');
      expect(model.updatedAt, DateTime.parse('2026-09-27T10:00:00.000'));
      expect(model.dirty, isTrue);
    });

    test('fromMap handles missing or null fields gracefully', () {
      final map = <String, Object?>{
        'title': 'Catatan Minimal',
      };

      final model = NoteModel.fromMap(map);

      expect(model.id, isNull);
      expect(model.title, 'Catatan Minimal');
      expect(model.body, '');
      expect(model.dirty, isFalse);
    });

    test('toMap converts NoteModel into valid SQLite key-value map', () {
      final model = NoteModel(
        id: 42,
        title: 'Beli Kopi',
        body: 'Arabica beans',
        updatedAt: DateTime(2026, 9, 27, 8, 30),
        dirty: true,
      );

      final map = model.toMap();

      expect(map['id'], 42);
      expect(map['title'], 'Beli Kopi');
      expect(map['body'], 'Arabica beans');
      expect(map['dirty'], 1);
      expect(map['updated_at'], contains('2026-09-27'));
    });

    test('toEntity converts NoteModel into pure Domain Entity Note', () {
      final model = NoteModel(
        id: 10,
        title: 'Domain Entity',
        body: 'Clean Arch',
        updatedAt: DateTime(2026, 9, 27),
        dirty: false,
      );

      final entity = model.toEntity();

      expect(entity, isA<Note>());
      expect(entity.id, 10);
      expect(entity.title, 'Domain Entity');
      expect(entity.dirty, isFalse);
    });

    test('fromEntity creates NoteModel from pure Domain Entity', () {
      final entity = Note(
        id: 99,
        title: 'From Entity',
        body: 'Testing',
        updatedAt: DateTime(2026, 9, 27),
        dirty: true,
      );

      final model = NoteModel.fromEntity(entity);

      expect(model.id, 99);
      expect(model.title, 'From Entity');
      expect(model.dirty, isTrue);
    });
  });
}

