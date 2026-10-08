import 'package:dio/dio.dart';
import 'auth_repository.dart';
import 'token_store.dart';

/// Membangun instance Dio dengan interceptor autentikasi dan auto-refresh token.
///
/// Alur Kerja Interceptor:
/// 1. onRequest: Menyisipkan header `Authorization: Bearer <access_token>` secara otomatis.
/// 2. onError (401 Unauthorized):
///    - Mengambil refresh token dari secure storage.
///    - Meminta access token baru ke backend / AuthRepository.
///    - Menyimpan access token baru ke secure storage.
///    - Melakukan retry request asli 1 kali dengan access token baru.
///    - Jika refresh gagal / kedaluwarsa -> bersihkan TokenStore (logout).
Dio buildApiClient(TokenStore store, AuthRepository auth, {String? baseUrl}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl ?? 'https://example-campus-api.test',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final access = await store.readAccess();
        if (access != null && access.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $access';
        }
        handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          final refresh = await store.readRefresh();
          if (refresh == null || refresh.isEmpty) {
            return handler.next(e);
          }

          try {
            // Coba tukar refresh token dengan access token baru
            final renewed = await auth.refresh(refresh);
            await store.save(access: renewed, refresh: refresh);

            // Perbarui header Authorization pada request yang gagal dan ulangi 1 kali
            final requestOptions = e.requestOptions;
            requestOptions.headers['Authorization'] = 'Bearer $renewed';

            final retryResponse = await dio.fetch(requestOptions);
            return handler.resolve(retryResponse);
          } catch (_) {
            // Jika refresh token juga mati / kedaluwarsa -> bersihkan secure storage
            await store.clear();
          }
        }
        handler.next(e);
      },
    ),
  );

  return dio;
}
