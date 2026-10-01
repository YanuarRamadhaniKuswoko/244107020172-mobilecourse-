import 'package:flutter_test/flutter_test.dart';
import 'package:week5_offline_notes/data/local/note.dart';
import 'package:week5_offline_notes/data/models/post.dart';
import 'package:week5_offline_notes/data/repositories/note_repository.dart';
import 'package:week5_offline_notes/data/sync.dart';

class MockNoteRepositoryForSync extends NoteRepository {
  MockNoteRepositoryForSync({int initialDirty = 3})
      : _dirtyCount = initialDirty,
        super(openDb: () => throw UnimplementedError());

  int _dirtyCount;

  @override
  Future<int> countDirty() async => _dirtyCount;

  @override
  Future<void> markAllSynced() async {
    _dirtyCount = 0;
  }
}

void main() {
  group('Post Model Serialization', () {
    test('Post.fromJson parsing defensively with fallback', () {
      final json = {
        'id': 101,
        'userId': 5,
        'title': 'Test Post',
        'body': 'Test Body Content',
      };
      final post = Post.fromJson(json);
      expect(post.id, 101);
      expect(post.userId, 5);
      expect(post.title, 'Test Post');
      expect(post.body, 'Test Body Content');
      expect(post.toJson(), json);
    });

    test('Post.fromJson handles null and missing fields safely', () {
      final post = Post.fromJson({});
      expect(post.id, 0);
      expect(post.userId, 0);
      expect(post.title, '');
      expect(post.body, '');
    });
  });

  group('Sync Logic', () {
    test('syncNotes uploads dirty notes and marks all synced', () async {
      final repo = MockNoteRepositoryForSync(initialDirty: 4);
      final synced = await syncNotes(repo);
      expect(synced, 4);
      expect(await repo.countDirty(), 0);
    });

    test('syncNotes does nothing if dirty count is 0', () async {
      final repo = MockNoteRepositoryForSync(initialDirty: 0);
      final synced = await syncNotes(repo);
      expect(synced, 0);
      expect(await repo.countDirty(), 0);
    });
  });

  group('Note Model', () {
    test('Note copyWith preserves or replaces fields correctly', () {
      final original = Note(
        id: 1,
        title: 'Original Title',
        body: 'Original Body',
        updatedAt: DateTime(2026, 1, 1),
        dirty: false,
      );

      final modified = original.copyWith(
        title: 'New Title',
        dirty: true,
      );

      expect(modified.id, 1);
      expect(modified.title, 'New Title');
      expect(modified.body, 'Original Body');
      expect(modified.dirty, isTrue);
    });
  });
}
