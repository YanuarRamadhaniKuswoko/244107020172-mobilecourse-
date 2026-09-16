import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/comment.dart';
import 'providers.dart';
import 'repositories/comment_repository.dart';

/// Provider untuk CommentRepository menggunakan client Dio terpusat.
final commentRepositoryProvider = Provider<CommentRepository>(
  (ref) => CommentRepository(ref.watch(dioProvider)),
);

/// AsyncNotifier untuk mengelola state asynchronous list Comment.
class CommentListNotifier extends AsyncNotifier<List<Comment>> {
  @override
  Future<List<Comment>> build() async {
    // Nilai awal kosong sebelum postId diminta
    return [];
  }

  /// Mengambil komentar berdasarkan postId dan mengelola state AsyncLoading/AsyncData/AsyncError.
  Future<void> fetchByPostId(int postId) async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(commentRepositoryProvider);
      state = AsyncData(await repository.fetchComments(postId));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

/// Provider AsyncNotifier untuk CommentListNotifier.
final commentListProvider =
    AsyncNotifierProvider<CommentListNotifier, List<Comment>>(
  CommentListNotifier.new,
  retry: (retryCount, error) => null,
);

/// FutureProvider family untuk akses deklaratif langsung berdasarkan postId.
final commentsByPostIdProvider =
    FutureProvider.family<List<Comment>, int>((ref, postId) async {
  final repository = ref.watch(commentRepositoryProvider);
  return repository.fetchComments(postId);
});

/// Helper khusus testing untuk membaca state data komentar setelah pemanggilan.
Future<List<Comment>> readCommentsOnce(
  ProviderContainer container,
  int postId,
) async {
  await container.read(commentListProvider.notifier).fetchByPostId(postId);
  final state = container.read(commentListProvider);
  if (state.hasError) {
    throw state.error!;
  }
  return state.requireValue;
}

/// Helper khusus testing untuk membaca error state komentar.
Future<Object?> readCommentsErrorOnce(
  ProviderContainer container,
  int postId,
) async {
  await container.read(commentListProvider.notifier).fetchByPostId(postId);
  final state = container.read(commentListProvider);
  return state.error;
}
