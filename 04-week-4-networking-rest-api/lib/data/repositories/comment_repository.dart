import 'package:dio/dio.dart';
import '../models/comment.dart';

/// Repository untuk mengakses endpoint komentar dari JSONPlaceholder.
/// Bertindak sebagai single source of truth untuk data komentar
/// dan mengisolasi logika HTTP/Dio dari lapisan UI dan State Management.
class CommentRepository {
  CommentRepository(this._dio);
  final Dio _dio;

  /// Mengambil daftar komentar untuk suatu post berdasarkan [postId].
  /// Menggunakan query parameter `?postId={id}`.
  Future<List<Comment>> fetchComments(int postId) async {
    final response = await _dio.get<List>(
      '/comments',
      queryParameters: {'postId': postId},
    );
    final data = response.data ?? [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(Comment.fromJson)
        .toList();
  }
}
