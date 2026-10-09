import '../../../../core/failures.dart';
import '../repositories/note_repository.dart';

class SyncNotes {
  const SyncNotes(this._repository);
  final NoteRepository _repository;

  Future<({int syncedCount, Failure? failure})> call() {
    return _repository.syncNotes();
  }
}

