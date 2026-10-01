import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:week5_offline_notes/data/local/note.dart';
import 'package:week5_offline_notes/data/repositories/note_repository.dart';

class FakeNoteRepository extends NoteRepository {
  FakeNoteRepository({this.items = const [], this.throwError = false})
      : super(openDb: () => throw UnimplementedError());

  final List<Note> items;
  final bool throwError;

  @override
  Future<List<Note>> fetchNotes() async {
    if (throwError) throw Exception('db locked (simulasi)');
    return items;
  }

  @override
  Future<Note?> getNoteById(int id) async {
    if (throwError) throw Exception('db locked (simulasi)');
    final matches = items.where((n) => n.id == id);
    return matches.isNotEmpty ? matches.first : null;
  }

  @override
  Future<int> countDirty() =>
      Future.value(items.where((n) => n.dirty).length);
}

void main() {
  test('fromMap aman terhadap field yang hilang', () {
    final note = Note.fromMap({'title': 'Belanja'});
    expect(note.title, 'Belanja');
    expect(note.body, '');
    expect(note.dirty, isFalse);
  });

  test('flag dirty bertahan pada serialisasi', () {
    final note = Note(
      title: 'a',
      updatedAt: DateTime(2026, 9, 18),
      dirty: true,
    );
    final restored = Note.fromMap(note.toMap());
    expect(restored.dirty, isTrue);
  });

  test('provider sukses dengan repository palsu', () async {
    final container = ProviderContainer(
      overrides: [
        noteRepositoryProvider.overrideWithValue(
          FakeNoteRepository(items: [
            Note(id: 1, title: 'Tes', updatedAt: DateTime.now()),
          ]),
        ),
      ],
    );
    addTearDown(container.dispose);
    final notes = await container.read(notesProvider.future);
    expect(notes.length, 1);
    expect(notes.first.title, 'Tes');
  });

  test('provider error dengan repository palsu', () async {
    final container = ProviderContainer(
      overrides: [
        noteRepositoryProvider.overrideWithValue(
          FakeNoteRepository(throwError: true),
        ),
      ],
    );
    addTearDown(container.dispose);
    await expectLater(
      container.read(notesProvider.future),
      throwsA(isA<Exception>()),
    );
  });

  test('noteDetailProvider membaca catatan dari repository lokal berdasarkan id', () async {
    final targetNote = Note(
      id: 42,
      title: 'Catatan Spesifik',
      body: 'Isi detail catatan',
      updatedAt: DateTime.now(),
    );

    final container = ProviderContainer(
      overrides: [
        noteRepositoryProvider.overrideWithValue(
          FakeNoteRepository(items: [targetNote]),
        ),
      ],
    );
    addTearDown(container.dispose);

    final Note? note = await container.read(noteDetailProvider(42).future);
    expect(note, isNotNull);
    expect(note?.id, 42);
    expect(note?.title, 'Catatan Spesifik');

    final Note? missingNote =
        await container.read(noteDetailProvider(999).future);
    expect(missingNote, isNull);
  });
}
