import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:sqflite/sqflite.dart';
import 'local/db.dart';
import 'models/post.dart';
import 'repositories/note_repository.dart';

/// Fungsi pembantu sinkronisasi catatan sesuai modul Codelab
Future<int> syncNotes(NoteRepository repo) async {
  final dirtyCount = await repo.countDirty();
  if (dirtyCount == 0) return 0;
  // Simulasi upload: pada project nyata, kirim tiap catatan dirty
  // ke REST API di sini, lalu tandai bersih bila server menjawab 2xx.
  await Future.delayed(const Duration(seconds: 1));
  await repo.markAllSynced();
  return dirtyCount;
}

/// Service untuk menangani sinkronisasi dan cache-first SQLite untuk data API
class SyncService {
  SyncService({
    Dio? dio,
    Future<Database> Function()? openDb,
  })  : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: 'https://jsonplaceholder.typicode.com',
                connectTimeout: const Duration(seconds: 5),
                receiveTimeout: const Duration(seconds: 5),
              ),
            ),
        _openDb = openDb ?? openNotesDb;

  final Dio _dio;
  final Future<Database> Function() _openDb;

  /// Membaca cached posts dari SQLite (tabel cached_posts)
  Future<List<Post>> readCachedPosts() async {
    try {
      final db = await _openDb();
      final rows = await db.query('cached_posts', orderBy: 'id ASC');
      return rows.map((row) {
        final payloadStr = row['payload'] as String;
        final jsonMap = jsonDecode(payloadStr) as Map<String, dynamic>;
        return Post.fromJson(jsonMap);
      }).toList();
    } catch (_) {
      return [];
    }
  }

  /// Menyimpan daftar posts ke SQLite (tabel cached_posts)
  Future<void> saveCachedPosts(List<Post> posts) async {
    final db = await _openDb();
    final batch = db.batch();
    await db.delete('cached_posts');
    final nowIso = DateTime.now().toIso8601String();
    for (final post in posts) {
      batch.insert(
        'cached_posts',
        {
          'id': post.id,
          'payload': jsonEncode(post.toJson()),
          'cached_at': nowIso,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  /// Mengambil data posts dari server API
  Future<List<Post>> fetchRemotePosts() async {
    final response = await _dio.get('/posts');
    final data = response.data as List<dynamic>;
    return data.map((e) => Post.fromJson(e as Map<String, dynamic>)).toList();
  }
}
