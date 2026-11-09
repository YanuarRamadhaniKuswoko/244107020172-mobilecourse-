import 'package:dio/dio.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/failures.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../models/note_model.dart';

class NoteRepositoryImpl implements NoteRepository {
  NoteRepositoryImpl({required this.openDb, Dio? dio})
    : _dio = dio ?? _createDefaultDio();

  final Future<Database> Function() openDb;
  final Dio _dio;

  static Dio _createDefaultDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://jsonplaceholder.typicode.com',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );

    // Section 6.3 Jobsheet: Dio Interceptor untuk logging dan error handling
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: false,
        requestBody: false,
        responseHeader: false,
        responseBody: false,
      ),
    );

    return dio;
  }

  @override
  Future<({List<Note> notes, Failure? failure})> fetchNotes() async {
    try {
      final db = await openDb();
      final rows = await db.query('notes', orderBy: 'updated_at DESC');
      final notes = rows.map((r) => NoteModel.fromMap(r).toEntity()).toList();
      return (notes: notes, failure: null);
    } catch (e) {
      return (
        notes: const <Note>[],
        failure: LocalFailure('Gagal membaca catatan dari database lokal: $e'),
      );
    }
  }

  @override
  Future<({List<Note> notes, bool hasMore, Failure? failure})> fetchNotesPaginated({
    required int page,
    int pageSize = 10,
  }) async {
    try {
      final db = await openDb();
      final offset = (page - 1) * pageSize;
      final rows = await db.query(
        'notes',
        orderBy: 'updated_at DESC',
        limit: pageSize,
        offset: offset,
      );

      final totalRows = await db.rawQuery('SELECT COUNT(*) as c FROM notes');
      final totalCount = (totalRows.first['c'] as num?)?.toInt() ?? 0;
      final notes = rows.map((r) => NoteModel.fromMap(r).toEntity()).toList();
      final hasMore = (offset + notes.length) < totalCount;

      return (notes: notes, hasMore: hasMore, failure: null);
    } catch (e) {
      return (
        notes: const <Note>[],
        hasMore: false,
        failure: LocalFailure('Gagal memuat catatan paginasi: $e'),
      );
    }
  }

  /// Section 6.2 Jobsheet: Stale-While-Revalidate caching pattern
  @override
  Future<({List<Note> notes, Failure? failure})> fetchNotesWithCache({
    bool forceRefresh = false,
  }) async {
    try {
      final db = await openDb();
      // 1. Tampilkan cache lokal segera (jika ada)
      final localRows = await db.query('notes', orderBy: 'updated_at DESC');
      final cached = localRows.map((r) => NoteModel.fromMap(r).toEntity()).toList();

      if (cached.isNotEmpty && !forceRefresh) {
        return (notes: cached, failure: null);
      }

      // 2. Fetch data baru di background dari API
      try {
        final response = await _dio.get('/posts?_limit=10');
        final data = response.data as List<dynamic>;
        final now = DateTime.now();

        // 3. Simpan / perbarui local cache
        for (final item in data) {
          final id = item['id'] as int?;
          final title = item['title'] as String? ?? '';
          final body = item['body'] as String? ?? '';

          if (id != null) {
            final existing = await db.query(
              'notes',
              where: 'id = ?',
              whereArgs: [id],
            );
            if (existing.isEmpty) {
              await db.insert('notes', {
                'id': id,
                'title': title,
                'body': body,
                'updated_at': now.toIso8601String(),
                'dirty': 0,
              });
            }
          }
        }

        // Ambil data terbaru dari cache lokal
        final updatedRows = await db.query('notes', orderBy: 'updated_at DESC');
        final fresh = updatedRows.map((r) => NoteModel.fromMap(r).toEntity()).toList();
        return (notes: fresh, failure: null);
      } catch (dioErr) {
        // Fallback: Jika network gagal namun ada cache lokal, kembalikan cache lokal
        if (cached.isNotEmpty) {
          return (notes: cached, failure: null);
        }
        return (
          notes: const <Note>[],
          failure: NetworkFailure('Gagal mengambil data dari server: $dioErr'),
        );
      }
    } catch (e) {
      return (
        notes: const <Note>[],
        failure: LocalFailure('Gagal memuat cache catatan: $e'),
      );
    }
  }

  @override
  Future<({Note? note, Failure? failure})> getNoteById(int id) async {
    try {
      final db = await openDb();
      final rows = await db.query('notes', where: 'id = ?', whereArgs: [id]);
      if (rows.isEmpty) {
        return (
          note: null,
          failure: const LocalFailure('Catatan tidak ditemukan'),
        );
      }
      final entity = NoteModel.fromMap(rows.first).toEntity();
      return (note: entity, failure: null);
    } catch (e) {
      return (
        note: null,
        failure: LocalFailure('Gagal mengambil catatan ID $id: $e'),
      );
    }
  }

  @override
  Future<({Note? note, Failure? failure})> addNote({
    required String title,
    String body = '',
  }) async {
    try {
      final db = await openDb();
      final now = DateTime.now();
      final model = NoteModel(
        title: title,
        body: body,
        updatedAt: now,
        dirty: true,
      );
      final id = await db.insert('notes', model.toMap());
      final created = Note(
        id: id,
        title: title,
        body: body,
        updatedAt: now,
        dirty: true,
      );
      return (note: created, failure: null);
    } catch (e) {
      return (note: null, failure: LocalFailure('Gagal menyimpan catatan: $e'));
    }
  }

  @override
  Future<({Note? note, Failure? failure})> updateNote(Note note) async {
    if (note.id == null) {
      return (
        note: null,
        failure: const LocalFailure('Tidak dapat memperbarui catatan tanpa ID'),
      );
    }
    try {
      final db = await openDb();
      final now = DateTime.now();
      final updatedModel = NoteModel(
        id: note.id,
        title: note.title,
        body: note.body,
        updatedAt: now,
        dirty: true,
      );
      await db.update(
        'notes',
        updatedModel.toMap(),
        where: 'id = ?',
        whereArgs: [note.id],
      );
      return (note: updatedModel.toEntity(), failure: null);
    } catch (e) {
      return (
        note: null,
        failure: LocalFailure('Gagal memperbarui catatan: $e'),
      );
    }
  }

  @override
  Future<({bool success, Failure? failure})> deleteNote(int id) async {
    try {
      final db = await openDb();
      final count = await db.delete('notes', where: 'id = ?', whereArgs: [id]);
      return (success: count > 0, failure: null);
    } catch (e) {
      return (
        success: false,
        failure: LocalFailure('Gagal menghapus catatan: $e'),
      );
    }
  }

  @override
  Future<({int count, Failure? failure})> countDirty() async {
    try {
      final db = await openDb();
      final rows = await db.rawQuery(
        'SELECT COUNT(*) AS c FROM notes WHERE dirty = 1',
      );
      final count = (rows.first['c'] as num?)?.toInt() ?? 0;
      return (count: count, failure: null);
    } catch (e) {
      return (
        count: 0,
        failure: LocalFailure('Gagal menghitung catatan dirty: $e'),
      );
    }
  }

  @override
  Future<({int syncedCount, Failure? failure})> syncNotes() async {
    try {
      final db = await openDb();
      final dirtyRows = await db.query('notes', where: 'dirty = 1');
      if (dirtyRows.isEmpty) {
        return (syncedCount: 0, failure: null);
      }

      int synced = 0;
      for (final row in dirtyRows) {
        final id = (row['id'] as num?)?.toInt();
        final title = row['title'] as String? ?? '';
        final body = row['body'] as String? ?? '';

        try {
          await _dio.post(
            '/posts',
            data: {'title': title, 'body': body, 'userId': 1},
          );

          if (id != null) {
            await db.update(
              'notes',
              {'dirty': 0},
              where: 'id = ?',
              whereArgs: [id],
            );
          }
          synced++;
        } on DioException catch (dioErr) {
          return (
            syncedCount: synced,
            failure: NetworkFailure(
              'Gagal sinkronisasi data remote: ${dioErr.message ?? dioErr.type.name}',
            ),
          );
        }
      }

      return (syncedCount: synced, failure: null);
    } catch (e) {
      return (
        syncedCount: 0,
        failure: LocalFailure('Gagal proses sinkronisasi database: $e'),
      );
    }
  }
}
