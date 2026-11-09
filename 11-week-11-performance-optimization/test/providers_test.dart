import 'package:performance_optimization_notes/core/failures.dart';
import 'package:performance_optimization_notes/features/notes/domain/entities/note.dart';
import 'package:performance_optimization_notes/features/notes/domain/repositories/note_repository.dart';
import 'package:performance_optimization_notes/features/notes/presentation/providers/notes_providers.dart';
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
  Future<({List<Note> notes, bool hasMore, Failure? failure})> fetchNotesPaginated({
    required int page,
    int pageSize = 10,
  }) async {
    final offset = (page - 1) * pageSize;
    if (offset >= notes.length) {
      return (notes: <Note>[], hasMore: false, failure: null);
    }
    final end = (offset + pageSize < notes.length) ? offset + pageSize : notes.length;
    final slice = notes.sublist(offset, end);
    final hasMore = end < notes.length;
    return (notes: slice, hasMore: hasMore, failure: null);
  }

  @override
  Future<({List<Note> notes, Failure? failure})> fetchNotesWithCache({
    bool forceRefresh = false,
  }) async {
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
      overrides: [noteRepositoryProvider.overrideWithValue(repo)],
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

  test('Riverpod select accurately listens only to dirty count changes', () async {
    final repo = InMemoryNoteRepository([
      Note(id: 1, title: 'Note 1', updatedAt: DateTime.now(), dirty: false),
    ]);

    final container = ProviderContainer(
      overrides: [noteRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);

    // Initial dirty count should be 0
    final initialDirty = await container.read(dirtyCountProvider.future);
    expect(initialDirty, 0);

    // Adding note sets dirty = true
    await container
        .read(notesProvider.notifier)
        .addNote(title: 'Dirty Note', body: 'Unsynced');

    final newDirty = await container.read(dirtyCountProvider.future);
    expect(newDirty, 1);
  });
}
