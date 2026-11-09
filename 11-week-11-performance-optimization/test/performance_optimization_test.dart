import 'package:flutter_test/flutter_test.dart';
import 'package:performance_optimization_notes/core/failures.dart';
import 'package:performance_optimization_notes/features/notes/domain/entities/note.dart';
import 'package:performance_optimization_notes/features/notes/domain/repositories/note_repository.dart';

class MockPerformanceNoteRepository implements NoteRepository {
  MockPerformanceNoteRepository({List<Note>? initialNotes})
      : _notes = initialNotes ?? [];

  final List<Note> _notes;
  final List<Note> _remoteServerPosts = [
    Note(
      id: 101,
      title: 'Remote Fresh Note 1',
      body: 'Content from API',
      updatedAt: DateTime.now(),
      dirty: false,
    ),
    Note(
      id: 102,
      title: 'Remote Fresh Note 2',
      body: 'Content from API',
      updatedAt: DateTime.now(),
      dirty: false,
    ),
  ];

  bool networkFails = false;

  @override
  Future<({List<Note> notes, Failure? failure})> fetchNotes() async {
    return (notes: List<Note>.unmodifiable(_notes), failure: null);
  }

  // Section 5.2 Jobsheet: Pagination (Infinite Scroll)
  @override
  Future<({List<Note> notes, bool hasMore, Failure? failure})> fetchNotesPaginated({
    required int page,
    int pageSize = 5,
  }) async {
    final offset = (page - 1) * pageSize;
    if (offset >= _notes.length) {
      return (notes: <Note>[], hasMore: false, failure: null);
    }
    final end = (offset + pageSize < _notes.length) ? offset + pageSize : _notes.length;
    final slice = _notes.sublist(offset, end);
    final hasMore = end < _notes.length;
    return (notes: slice, hasMore: hasMore, failure: null);
  }

  // Section 6.2 Jobsheet: Stale-While-Revalidate Caching Pattern
  @override
  Future<({List<Note> notes, Failure? failure})> fetchNotesWithCache({
    bool forceRefresh = false,
  }) async {
    // 1. Tampilkan cache segera (jika ada dan tidak forceRefresh)
    if (_notes.isNotEmpty && !forceRefresh) {
      return (notes: List<Note>.unmodifiable(_notes), failure: null);
    }

    // 2. Fetch data fresh dari remote server
    if (networkFails) {
      // Fallback ke cache lokal jika network gagal
      if (_notes.isNotEmpty) {
        return (notes: List<Note>.unmodifiable(_notes), failure: null);
      }
      return (
        notes: const <Note>[],
        failure: const NetworkFailure('Koneksi internet bermasalah'),
      );
    }

    // 3. Update cache lokal dengan data segar
    _notes.addAll(_remoteServerPosts);
    return (notes: List<Note>.unmodifiable(_notes), failure: null);
  }

  @override
  Future<({Note? note, Failure? failure})> addNote({
    required String title,
    String body = '',
  }) async {
    final note = Note(
      id: _notes.length + 1,
      title: title,
      body: body,
      updatedAt: DateTime.now(),
      dirty: true,
    );
    _notes.add(note);
    return (note: note, failure: null);
  }

  @override
  Future<({Note? note, Failure? failure})> getNoteById(int id) async {
    final matches = _notes.where((n) => n.id == id);
    if (matches.isEmpty) return (note: null, failure: const LocalFailure('Not found'));
    return (note: matches.first, failure: null);
  }

  @override
  Future<({Note? note, Failure? failure})> updateNote(Note note) async {
    final i = _notes.indexWhere((n) => n.id == note.id);
    if (i == -1) return (note: null, failure: const LocalFailure('Not found'));
    _notes[i] = note;
    return (note: note, failure: null);
  }

  @override
  Future<({bool success, Failure? failure})> deleteNote(int id) async {
    _notes.removeWhere((n) => n.id == id);
    return (success: true, failure: null);
  }

  @override
  Future<({int count, Failure? failure})> countDirty() async {
    return (count: _notes.where((n) => n.dirty).length, failure: null);
  }

  @override
  Future<({int syncedCount, Failure? failure})> syncNotes() async {
    int count = 0;
    for (int i = 0; i < _notes.length; i++) {
      if (_notes[i].dirty) {
        _notes[i] = _notes[i].copyWith(dirty: false);
        count++;
      }
    }
    return (syncedCount: count, failure: null);
  }
}

void main() {
  group('Jobsheet 11 - Performance Optimization Tests', () {
    test('Pagination correctly fetches pages and indicates hasMore flag', () async {
      final items = List.generate(
        12,
        (i) => Note(
          id: i + 1,
          title: 'Note ${i + 1}',
          body: 'Body ${i + 1}',
          updatedAt: DateTime.now(),
        ),
      );
      final repo = MockPerformanceNoteRepository(initialNotes: items);

      // Page 1: 5 items, hasMore = true
      final page1 = await repo.fetchNotesPaginated(page: 1, pageSize: 5);
      expect(page1.notes.length, 5);
      expect(page1.hasMore, isTrue);
      expect(page1.notes.first.title, 'Note 1');

      // Page 2: 5 items, hasMore = true
      final page2 = await repo.fetchNotesPaginated(page: 2, pageSize: 5);
      expect(page2.notes.length, 5);
      expect(page2.hasMore, isTrue);
      expect(page2.notes.first.title, 'Note 6');

      // Page 3: 2 items, hasMore = false
      final page3 = await repo.fetchNotesPaginated(page: 3, pageSize: 5);
      expect(page3.notes.length, 2);
      expect(page3.hasMore, isFalse);
      expect(page3.notes.last.title, 'Note 12');

      // Page 4: empty
      final page4 = await repo.fetchNotesPaginated(page: 4, pageSize: 5);
      expect(page4.notes.length, 0);
      expect(page4.hasMore, isFalse);
    });

    test('Stale-While-Revalidate returns cached data immediately', () async {
      final cachedNote = Note(
        id: 1,
        title: 'Cached Note',
        body: 'Local SQLite data',
        updatedAt: DateTime.now(),
      );
      final repo = MockPerformanceNoteRepository(initialNotes: [cachedNote]);

      // Cache-hit returns immediately without network
      final result = await repo.fetchNotesWithCache();
      expect(result.failure, isNull);
      expect(result.notes.length, 1);
      expect(result.notes.first.title, 'Cached Note');
    });

    test('Stale-While-Revalidate falls back gracefully to cache when network fails', () async {
      final cachedNote = Note(
        id: 1,
        title: 'Cached Offline Note',
        body: 'Local fallback',
        updatedAt: DateTime.now(),
      );
      final repo = MockPerformanceNoteRepository(initialNotes: [cachedNote]);
      repo.networkFails = true;

      // Force refresh with network failure still returns cache fallback
      final result = await repo.fetchNotesWithCache(forceRefresh: true);
      expect(result.failure, isNull);
      expect(result.notes.length, 1);
      expect(result.notes.first.title, 'Cached Offline Note');
    });

    test('Stale-While-Revalidate returns NetworkFailure if cache is empty and network fails', () async {
      final repo = MockPerformanceNoteRepository(initialNotes: []);
      repo.networkFails = true;

      final result = await repo.fetchNotesWithCache(forceRefresh: true);
      expect(result.failure, isA<NetworkFailure>());
      expect(result.notes, isEmpty);
    });
  });
}
