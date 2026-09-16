import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:week4_api/data/models/comment.dart';
import 'package:week4_api/data/comment_providers.dart';
import 'package:week4_api/data/repositories/comment_repository.dart';
import 'package:week4_api/data/providers.dart';

class FakeCommentRepository extends CommentRepository {
  FakeCommentRepository({this.items, this.throwError = false})
      : super(Dio());
  final List<Comment>? items;
  final bool throwError;

  @override
  Future<List<Comment>> fetchComments(int postId) async {
    if (throwError) {
      throw DioException(
        requestOptions: RequestOptions(path: '/comments'),
        type: DioExceptionType.connectionError,
      );
    }
    return items ?? const [];
  }
}

void main() {
  group('Comment Model Unit Tests', () {
    test('fromJson aman terhadap field yang hilang / null', () {
      final json = {'id': 10, 'postId': 1};
      final comment = Comment.fromJson(json);

      expect(comment.id, 10);
      expect(comment.postId, 1);
      expect(comment.name, '');
      expect(comment.email, '');
      expect(comment.body, '');
    });

    test('fromJson aman terhadap JSON kosong total (Edge Case)', () {
      final comment = Comment.fromJson({});

      expect(comment.id, 0);
      expect(comment.postId, 0);
      expect(comment.name, '');
      expect(comment.email, '');
      expect(comment.body, '');
    });

    test('toJson menghasilkan Map yang sesuai', () {
      const comment = Comment(
        postId: 1,
        id: 1,
        name: 'John Doe',
        email: 'john@example.com',
        body: 'Great article!',
      );

      final map = comment.toJson();
      expect(map['postId'], 1);
      expect(map['id'], 1);
      expect(map['name'], 'John Doe');
      expect(map['email'], 'john@example.com');
      expect(map['body'], 'Great article!');
    });
  });

  group('Comment Provider Unit Tests', () {
    test('commentListProvider sukses dengan FakeCommentRepository', () async {
      final container = ProviderContainer(
        overrides: [
          commentRepositoryProvider.overrideWithValue(
            FakeCommentRepository(items: [
              const Comment(
                postId: 1,
                id: 1,
                name: 'Jane Doe',
                email: 'jane@example.com',
                body: 'Very helpful content.',
              ),
            ]),
          ),
        ],
      );
      addTearDown(container.dispose);

      final comments = await readCommentsOnce(container, 1);
      expect(comments.length, 1);
      expect(comments.first.name, 'Jane Doe');
      expect(comments.first.email, 'jane@example.com');
    });

    test('commentListProvider error dengan FakeCommentRepository', () async {
      final container = ProviderContainer(
        overrides: [
          commentRepositoryProvider.overrideWithValue(
            FakeCommentRepository(throwError: true),
          ),
        ],
      );
      addTearDown(container.dispose);

      final err = await readCommentsErrorOnce(container, 1);
      expect(err, isA<DioException>());
      expect(friendlyErrorMessage(err!), contains('terhubung'));
    });

    test('friendlyErrorMessage memetakan error komentar dengan tepat', () {
      final err = DioException(
        requestOptions: RequestOptions(path: '/comments'),
        type: DioExceptionType.receiveTimeout,
      );
      expect(friendlyErrorMessage(err), contains('timeout'));
    });
  });
}
