import '../../../../core/failures.dart';
import '../entities/note.dart';

abstract class NoteRepository {
  Future<({List<Note> notes, Failure? failure})> fetchNotes();
  Future<({List<Note> notes, bool hasMore, Failure? failure})> fetchNotesPaginated({
    required int page,
    int pageSize,
  });
  Future<({List<Note> notes, Failure? failure})> fetchNotesWithCache({
    bool forceRefresh,
  });
  Future<({Note? note, Failure? failure})> getNoteById(int id);
  Future<({Note? note, Failure? failure})> addNote({
    required String title,
    String body,
  });
  Future<({Note? note, Failure? failure})> updateNote(Note note);
  Future<({bool success, Failure? failure})> deleteNote(int id);
  Future<({int count, Failure? failure})> countDirty();
  Future<({int syncedCount, Failure? failure})> syncNotes();
}
