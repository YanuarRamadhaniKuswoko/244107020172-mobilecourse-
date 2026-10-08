import 'package:campus_notify/data/api_errors.dart';
import 'package:campus_notify/data/auth_repository.dart';
import 'package:campus_notify/routes.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeTokenStore {
  String? access;
  String? refresh;

  Future<void> save({required String access, required String refresh}) async {
    this.access = access;
    this.refresh = refresh;
  }

  Future<String?> readAccess() async => access;
  Future<String?> readRefresh() async => refresh;
  Future<void> clear() async {
    access = null;
    refresh = null;
  }
}

void main() {
  group('Testing Praktikum 1: Autentikasi, Route Handler, dan Token Store', () {
    test('routeFromMessage menangani route kosong dan tanpa slash', () {
      expect(routeFromMessage({}), '/');
      expect(routeFromMessage({'route': 'pengumuman/3'}), '/pengumuman/3');
      expect(routeFromMessage({'route': '/pengumuman/3'}), '/pengumuman/3');
      expect(routeFromMessage({'route': ''}), '/');
    });

    test('data payload membawa id pengumuman dan rute tujuan', () {
      const data = {'route': '/pengumuman/3', 'id': '3'};
      expect(data['id'], '3');
      expect(routeFromMessage(data), '/pengumuman/3');
    });

    test('FakeTokenStore dapat menyimpan, membaca, dan menghapus token', () async {
      final store = FakeTokenStore();
      expect(await store.readAccess(), isNull);
      expect(await store.readRefresh(), isNull);

      await store.save(access: 'token_access_123', refresh: 'token_refresh_456');
      expect(await store.readAccess(), 'token_access_123');
      expect(await store.readRefresh(), 'token_refresh_456');

      await store.clear();
      expect(await store.readAccess(), isNull);
      expect(await store.readRefresh(), isNull);
    });

    test('AuthRepository login berhasil dengan format email dan password valid', () async {
      final repo = AuthRepository();
      final session = await repo.login(
        email: 'student@polinema.ac.id',
        password: 'password123',
      );

      expect(session.access.startsWith('mock-access-for-'), isTrue);
      expect(session.refresh.startsWith('mock-refresh-for-'), isTrue);
    });

    test('AuthRepository login melempar error saat format input salah', () async {
      final repo = AuthRepository();
      expect(
        () => repo.login(email: 'invalid-email', password: '123'),
        throwsA(isA<Exception>()),
      );
    });

    test('AuthRepository refresh token mengembalikan access token baru', () async {
      final repo = AuthRepository();
      final newAccess = await repo.refresh('mock-refresh-valid');
      expect(newAccess.startsWith('mock-access-renewed-'), isTrue);
    });

    test('Refresh token kosong / expired memaksa login ulang', () async {
      final store = FakeTokenStore()..refresh = '';
      final needsLogin = (await store.readRefresh() ?? '').isEmpty;
      expect(needsLogin, isTrue);
    });

    test('ApiErrorMapper menghasilkan pesan yang ramah pengguna', () {
      final dio401 = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 401,
        ),
        type: DioExceptionType.badResponse,
      );

      final message = ApiErrorMapper.toUserFriendlyMessage(dio401);
      expect(message.contains('401 Unauthorized'), isTrue);
      expect(message.contains('masuk kembali'), isTrue);
    });
  });
}
