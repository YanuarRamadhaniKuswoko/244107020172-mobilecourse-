import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/notes_database.dart';
import '../../data/repositories/note_repository_impl.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../../domain/usecases/add_note.dart';
import '../../domain/usecases/delete_note.dart';
import '../../domain/usecases/get_notes.dart';
import '../../domain/usecases/sync_notes.dart';
import '../../domain/usecases/update_note.dart';

/// 1. Data Layer: Repository Provider dengan dependency injection
final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepositoryImpl(openDb: openNotesDb);
});

/// 2. Domain Layer: Use cases menerima interface NoteRepository
final getNotesProvider = Provider<GetNotes>((ref) {
  return GetNotes(ref.watch(noteRepositoryProvider));
});

final addNoteUseCaseProvider = Provider<AddNote>((ref) {
  return AddNote(ref.watch(noteRepositoryProvider));
});

final updateNoteUseCaseProvider = Provider<UpdateNote>((ref) {
  return UpdateNote(ref.watch(noteRepositoryProvider));
});

final deleteNoteUseCaseProvider = Provider<DeleteNote>((ref) {
  return DeleteNote(ref.watch(noteRepositoryProvider));
});

final syncNotesUseCaseProvider = Provider<SyncNotes>((ref) {
  return SyncNotes(ref.watch(noteRepositoryProvider));
});

/// 3. Presentation Layer: State management reaktif menggunakan AsyncNotifier
final notesProvider =
    AsyncNotifierProvider<NotesNotifier, List<Note>>(NotesNotifier.new);

class NotesNotifier extends AsyncNotifier<List<Note>> {
  @override
  Future<List<Note>> build() async {
    final getNotes = ref.watch(getNotesProvider);
    final result = await getNotes();
    if (result.failure != null) {
      throw Exception(result.failure!.message);
    }
    return result.notes;
  }

  Future<void> addNote({required String title, String body = ''}) async {
    final addNoteUseCase = ref.read(addNoteUseCaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final res = await addNoteUseCase(title: title, body: body);
      if (res.failure != null) {
        throw Exception(res.failure!.message);
      }
      ref.invalidate(dirtyCountProvider);
      final listRes = await ref.read(getNotesProvider)();
      if (listRes.failure != null) {
        throw Exception(listRes.failure!.message);
      }
      return listRes.notes;
    });
  }

  Future<void> updateNote(Note note) async {
    final updateNoteUseCase = ref.read(updateNoteUseCaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final res = await updateNoteUseCase(note);
      if (res.failure != null) {
        throw Exception(res.failure!.message);
      }
      ref.invalidate(dirtyCountProvider);
      final listRes = await ref.read(getNotesProvider)();
      if (listRes.failure != null) {
        throw Exception(listRes.failure!.message);
      }
      return listRes.notes;
    });
  }

  Future<void> deleteNote(int id) async {
    final deleteNoteUseCase = ref.read(deleteNoteUseCaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final res = await deleteNoteUseCase(id);
      if (res.failure != null) {
        throw Exception(res.failure!.message);
      }
      ref.invalidate(dirtyCountProvider);
      final listRes = await ref.read(getNotesProvider)();
      if (listRes.failure != null) {
        throw Exception(listRes.failure!.message);
      }
      return listRes.notes;
    });
  }

  Future<int> sync() async {
    final syncNotesUseCase = ref.read(syncNotesUseCaseProvider);
    final res = await syncNotesUseCase();
    if (res.failure != null) {
      throw Exception(res.failure!.message);
    }
    ref.invalidateSelf();
    ref.invalidate(dirtyCountProvider);
    return res.syncedCount;
  }
}

/// Provider penghitung catatan yang belum sinkron (dirty = 1)
final dirtyCountProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(noteRepositoryProvider);
  final res = await repo.countDirty();
  if (res.failure != null) throw Exception(res.failure!.message);
  return res.count;
});

/// Provider family untuk mengambil detail catatan berdasarkan ID
final noteDetailProvider = FutureProvider.family<Note?, int>((ref, id) async {
  final repo = ref.watch(noteRepositoryProvider);
  final res = await repo.getNoteById(id);
  if (res.failure != null) throw Exception(res.failure!.message);
  return res.note;
});

