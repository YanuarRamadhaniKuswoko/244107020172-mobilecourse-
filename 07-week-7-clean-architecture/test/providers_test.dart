import 'package:clean_architecture_notes/core/failures.dart';
import 'package:clean_architecture_notes/features/notes/domain/entities/note.dart';
import 'package:clean_architecture_notes/features/notes/domain/repositories/note_repository.dart';
import 'package:clean_architecture_notes/features/notes/presentation/providers/notes_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class InMemoryNoteRepository implements NoteRepository {
  InMemoryNoteRepository([List<Note>? initial]) : notes = initial ?? [];

  final List<Note> notes;

  @override
  Future<({List<Note> notes, Failure? failure})> fetchNotes() async {
    return (notes: List.of(notes), failure: null);
  }

  @override
  Future<({Note? note, Failure? failure})> addNote({
    required String title,
    String body = '',
  }) async {
    final note = Note(
      id: notes.length + 1,
      title: title,
      body: body,
      updatedAt: DateTime.now(),
      dirty: true,
    );
    notes.add(note);
    return (note: note, failure: null);
  }

  @override
  Future<({Note? note, Failure? failure})> updateNote(Note note) async {
    final i = notes.indexWhere((n) => n.id == note.id);
    if (i != -1) {
      notes[i] = note;
      return (note: note, failure: null);
    }
    return (note: null, failure: const LocalFailure('Note not found'));
  }

  @override
  Future<({bool success, Failure? failure})> deleteNote(int id) async {
    notes.removeWhere((n) => n.id == id);
    return (success: true, failure: null);
  }

  @override
  Future<({Note? note, Failure? failure})> getNoteById(int id) async {
    final matches = notes.where((n) => n.id == id);
    if (matches.isNotEmpty) {
      return (note: matches.first, failure: null);
    }
    return (note: null, failure: const LocalFailure('Note not found'));
  }

  @override
  Future<({int count, Failure? failure})> countDirty() async {
    return (count: notes.where((n) => n.dirty).length, failure: null);
  }

  @override
  Future<({int syncedCount, Failure? failure})> syncNotes() async {
    int count = 0;
    for (int i = 0; i < notes.length; i++) {
      if (notes[i].dirty) {
        notes[i] = notes[i].copyWith(dirty: false);
        count++;
      }
    }
    return (syncedCount: count, failure: null);
  }
}

void main() {
  test('Riverpod noteRepositoryProvider overrides cleanly with in-memory repository', () async {
    final repo = InMemoryNoteRepository([
      Note(id: 1, title: 'Item 1', updatedAt: DateTime(2026, 9, 27)),
    ]);

    final container = ProviderContainer(
      overrides: [
        noteRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);

    final notes = await container.read(notesProvider.future);
    expect(notes.length, 1);
    expect(notes.first.title, 'Item 1');

    // Add note through notifier
    await container
        .read(notesProvider.notifier)
        .addNote(title: 'Item 2', body: 'Body 2');

    final updatedNotes = await container.read(notesProvider.future);
    expect(updatedNotes.length, 2);
    expect(updatedNotes.any((n) => n.title == 'Item 2'), isTrue);
  });
}

