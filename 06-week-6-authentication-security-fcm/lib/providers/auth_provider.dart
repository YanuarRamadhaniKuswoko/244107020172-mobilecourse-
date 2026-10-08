import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/api_client.dart';
import '../data/auth_repository.dart';
import '../data/token_store.dart';

/// Provider instance untuk TokenStore
final tokenStoreProvider = Provider<TokenStore>((ref) {
  return TokenStore();
});

/// Provider instance untuk AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Provider instance untuk Dio ApiClient dengan auto-refresh interceptor
final apiClientProvider = Provider<Dio>((ref) {
  final store = ref.watch(tokenStoreProvider);
  final repo = ref.watch(authRepositoryProvider);
  return buildApiClient(store, repo);
});

/// State Notifier Provider untuk status autentikasi pengguna (true = logged in, false = logged out)
final authStateProvider =
    AsyncNotifierProvider<AuthNotifier, bool>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final token = await ref.watch(tokenStoreProvider).readAccess();
    return token != null && token.isNotEmpty;
  }

  /// Melakukan login dengan email dan password, lalu menyimpan token ke secure storage
  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final session = await ref
          .read(authRepositoryProvider)
          .login(email: email, password: password);

      await ref
          .read(tokenStoreProvider)
          .save(access: session.access, refresh: session.refresh);

      return true;
    });
  }

  /// Melakukan logout dan menghapus token dari secure storage
  Future<void> logout() async {
    state = const AsyncLoading();
    await ref.read(tokenStoreProvider).clear();
    state = const AsyncData(false);
  }

  /// Simulasi manual token refresh untuk demonstrasi rotasi token
  Future<String> manualRefreshToken() async {
    final store = ref.read(tokenStoreProvider);
    final repo = ref.read(authRepositoryProvider);

    final refresh = await store.readRefresh();
    if (refresh == null || refresh.isEmpty) {
      throw Exception('Tidak ada refresh token yang aktif');
    }

    final newAccess = await repo.refresh(refresh);
    await store.save(access: newAccess, refresh: refresh);
    ref.invalidateSelf();
    return newAccess;
  }
}

/// Provider pembantu untuk membaca token terpotong (masked) demi keamanan tampilan UI
final maskedTokenInfoProvider = FutureProvider<Map<String, String>>((ref) async {
  // Bergantung pada authState agar me-refresh saat login/logout
  final isLoggedIn = ref.watch(authStateProvider).value ?? false;
  if (!isLoggedIn) {
    return {'access': '-', 'refresh': '-'};
  }

  final store = ref.read(tokenStoreProvider);
  final access = await store.readAccess();
  final refresh = await store.readRefresh();

  String mask(String? val) {
    if (val == null || val.isEmpty) return '(Kosong)';
    if (val.length <= 12) return '$val...';
    return '${val.substring(0, 12)}... [TERENKRIPSI]';
  }

  return {
    'access': mask(access),
    'refresh': mask(refresh),
  };
});
