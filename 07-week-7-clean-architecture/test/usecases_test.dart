import 'package:clean_architecture_notes/core/failures.dart';
import 'package:clean_architecture_notes/features/notes/domain/entities/note.dart';
import 'package:clean_architecture_notes/features/notes/domain/repositories/note_repository.dart';
import 'package:clean_architecture_notes/features/notes/domain/usecases/add_note.dart';
import 'package:clean_architecture_notes/features/notes/domain/usecases/delete_note.dart';
import 'package:clean_architecture_notes/features/notes/domain/usecases/sync_notes.dart';
import 'package:clean_architecture_notes/features/notes/domain/usecases/update_note.dart';
import 'package:flutter_test/flutter_test.dart';

class MockNoteRepository implements NoteRepository {
  final List<Note> notes = [];
  bool shouldFail = false;

  @override
  Future<({List<Note> notes, Failure? failure})> fetchNotes() async {
    if (shouldFail) {
      return (notes: <Note>[], failure: const LocalFailure('Simulated failure'));
    }
    return (notes: List<Note>.unmodifiable(notes), failure: null);
  }

  @override
  Future<({Note? note, Failure? failure})> addNote({
    required String title,
    String body = '',
  }) async {
    if (shouldFail) {
      return (note: null, failure: const LocalFailure('Failed to add note'));
    }
    final created = Note(
      id: notes.length + 1,
      title: title,
      body: body,
      updatedAt: DateTime.now(),
      dirty: true,
    );
    notes.add(created);
    return (note: created, failure: null);
  }

  @override
  Future<({Note? note, Failure? failure})> updateNote(Note note) async {
    if (shouldFail) {
      return (note: null, failure: const LocalFailure('Failed to update note'));
    }
    final index = notes.indexWhere((n) => n.id == note.id);
    if (index == -1) {
      return (note: null, failure: const LocalFailure('Not found'));
    }
    final updated = note.copyWith(updatedAt: DateTime.now(), dirty: true);
    notes[index] = updated;
    return (note: updated, failure: null);
  }

  @override
  Future<({bool success, Failure? failure})> deleteNote(int id) async {
    if (shouldFail) {
      return (success: false, failure: const LocalFailure('Failed to delete'));
    }
    notes.removeWhere((n) => n.id == id);
    return (success: true, failure: null);
  }

  @override
  Future<({Note? note, Failure? failure})> getNoteById(int id) async {
    final matches = notes.where((n) => n.id == id);
    if (matches.isEmpty) {
      return (note: null, failure: const LocalFailure('Not found'));
    }
    return (note: matches.first, failure: null);
  }

  @override
  Future<({int count, Failure? failure})> countDirty() async {
    final count = notes.where((n) => n.dirty).length;
    return (count: count, failure: null);
  }

  @override
  Future<({int syncedCount, Failure? failure})> syncNotes() async {
    if (shouldFail) {
      return (
        syncedCount: 0,
        failure: const NetworkFailure('Simulated network error'),
      );
    }
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
  late MockNoteRepository repo;

  setUp(() {
    repo = MockNoteRepository();
  });

  group('AddNote UseCase', () {
    test('validates empty title and returns ValidationFailure', () async {
      final useCase = AddNote(repo);
      final result = await useCase(title: '   ', body: 'some content');
      expect(result.failure, isA<ValidationFailure>());
      expect(result.note, isNull);
      expect(repo.notes, isEmpty);
    });

    test('adds note successfully when valid title is provided', () async {
      final useCase = AddNote(repo);
      final result = await useCase(title: 'Tugas Mobile', body: 'Jobsheet 7');
      expect(result.failure, isNull);
      expect(result.note?.title, 'Tugas Mobile');
      expect(result.note?.body, 'Jobsheet 7');
      expect(result.note?.dirty, isTrue);
      expect(repo.notes.length, 1);
    });
  });

  group('UpdateNote UseCase', () {
    test('validates empty title on update', () async {
      final useCase = UpdateNote(repo);
      final note = Note(
        id: 1,
        title: '',
        updatedAt: DateTime.now(),
      );
      final result = await useCase(note);
      expect(result.failure, isA<ValidationFailure>());
    });

    test('updates note successfully', () async {
      final addUseCase = AddNote(repo);
      final created = await addUseCase(title: 'Judul Asli');

      final updateUseCase = UpdateNote(repo);
      final updated = await updateUseCase(
        created.note!.copyWith(title: 'Judul Diubah'),
      );
      expect(updated.failure, isNull);
      expect(updated.note?.title, 'Judul Diubah');
    });
  });

  group('DeleteNote UseCase', () {
    test('deletes note by id', () async {
      final addUseCase = AddNote(repo);
      final created = await addUseCase(title: 'Catatan Hapus');

      final deleteUseCase = DeleteNote(repo);
      final result = await deleteUseCase(created.note!.id!);
      expect(result.failure, isNull);
      expect(result.success, isTrue);
      expect(repo.notes, isEmpty);
    });
  });

  group('SyncNotes UseCase', () {
    test('syncs dirty notes and clears dirty flag', () async {
      final addUseCase = AddNote(repo);
      await addUseCase(title: 'Catatan 1');
      await addUseCase(title: 'Catatan 2');

      final syncUseCase = SyncNotes(repo);
      final result = await syncUseCase();
      expect(result.failure, isNull);
      expect(result.syncedCount, 2);
      expect(repo.notes.every((n) => !n.dirty), isTrue);
    });

    test('returns NetworkFailure on error', () async {
      repo.shouldFail = true;
      final syncUseCase = SyncNotes(repo);
      final result = await syncUseCase();
      expect(result.failure, isA<NetworkFailure>());
      expect(result.syncedCount, 0);
    });
  });
}
