import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:performance_optimization_notes/core/failures.dart';
import 'package:performance_optimization_notes/features/notes/domain/entities/note.dart';
import 'package:performance_optimization_notes/features/notes/domain/repositories/note_repository.dart';
import 'package:performance_optimization_notes/features/notes/presentation/pages/notes_page.dart';
import 'package:performance_optimization_notes/features/notes/presentation/providers/notes_providers.dart';
import 'package:performance_optimization_notes/features/notes/presentation/widgets/note_tile.dart';

class TestNoteRepository implements NoteRepository {
  TestNoteRepository(this.notes);
  final List<Note> notes;

  @override
  Future<({List<Note> notes, Failure? failure})> fetchNotes() async {
    return (notes: notes, failure: null);
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
    return (notes: slice, hasMore: end < notes.length, failure: null);
  }

  @override
  Future<({List<Note> notes, Failure? failure})> fetchNotesWithCache({
    bool forceRefresh = false,
  }) async {
    return (notes: notes, failure: null);
  }

  @override
  Future<({Note? note, Failure? failure})> addNote({
    required String title,
    String body = '',
  }) async {
    return (
      note: Note(
        id: 99,
        title: title,
        body: body,
        updatedAt: DateTime.now(),
        dirty: true,
      ),
      failure: null,
    );
  }

  @override
  Future<({Note? note, Failure? failure})> getNoteById(int id) async {
    return (note: notes.firstWhere((n) => n.id == id), failure: null);
  }

  @override
  Future<({Note? note, Failure? failure})> updateNote(Note note) async {
    return (note: note, failure: null);
  }

  @override
  Future<({bool success, Failure? failure})> deleteNote(int id) async {
    return (success: true, failure: null);
  }

  @override
  Future<({int count, Failure? failure})> countDirty() async {
    return (count: notes.where((n) => n.dirty).length, failure: null);
  }

  @override
  Future<({int syncedCount, Failure? failure})> syncNotes() async {
    return (syncedCount: 0, failure: null);
  }
}

void main() {
  testWidgets('NotesPage renders note cards cleanly', (tester) async {
    final fakeRepo = TestNoteRepository([
      Note(
        id: 1,
        title: 'Catatan Kuliah Mobile',
        body: 'Clean Architecture feature-first',
        updatedAt: DateTime(2026, 9, 27, 10, 0),
        dirty: true,
      ),
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [noteRepositoryProvider.overrideWithValue(fakeRepo)],
        child: const MaterialApp(home: NotesPage()),
      ),
    );

    // Pump to resolve AsyncNotifier and page load
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Catatan Offline (Clean Arch)'), findsOneWidget);
    expect(find.text('Catatan Kuliah Mobile'), findsOneWidget);
    expect(find.text('Clean Architecture feature-first'), findsOneWidget);
    expect(find.text('Belum Sinkron (Offline)'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('NotesPage wraps NoteTile in RepaintBoundary for paint isolation', (tester) async {
    final fakeRepo = TestNoteRepository([
      Note(
        id: 1,
        title: 'Optimasi Paint',
        body: 'RepaintBoundary test',
        updatedAt: DateTime.now(),
        dirty: false,
      ),
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [noteRepositoryProvider.overrideWithValue(fakeRepo)],
        child: const MaterialApp(home: NotesPage()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify NoteTile is present and descendant of RepaintBoundary
    expect(find.byType(NoteTile), findsOneWidget);
    final repaintBoundaries = find.ancestor(
      of: find.byType(NoteTile),
      matching: find.byType(RepaintBoundary),
    );
    expect(repaintBoundaries, findsWidgets);
  });

  testWidgets('NotesPage renders extracted const NotesHeaderBanner and EmptyNotesView when empty', (tester) async {
    final fakeRepo = TestNoteRepository([]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [noteRepositoryProvider.overrideWithValue(fakeRepo)],
        child: const MaterialApp(home: NotesPage()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(NotesHeaderBanner), findsOneWidget);
    expect(find.byType(EmptyNotesView), findsOneWidget);
    expect(find.text('Belum ada catatan'), findsOneWidget);
  });
}
