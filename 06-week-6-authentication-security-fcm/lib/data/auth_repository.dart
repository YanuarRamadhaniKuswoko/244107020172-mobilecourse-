/// Model sesi autentikasi yang menyimpan access token dan refresh token.
class AuthSession {
  const AuthSession({required this.access, required this.refresh});
  final String access;
  final String refresh;
}

/// Repository untuk mengelola autentikasi pengguna.
/// Saat backend Firebase / REST API kampus sudah siap, mock ini dapat langsung
/// diganti dengan FirebaseAuth.instance.signInWithEmailAndPassword atau API client.
class AuthRepository {
  /// Melakukan login dengan email dan password.
  /// Mensimulasikan pembuatan JWT access token dan refresh token.
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (!email.contains('@') || password.length < 6) {
      throw Exception('Email tidak valid atau kata sandi minimal 6 karakter');
    }

    // Simulasi token JWT
    return AuthSession(
      access: 'mock-access-for-${email.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}',
      refresh: 'mock-refresh-for-${email.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}',
    );
  }

  /// Menukar refresh token yang valid dengan access token baru.
  Future<String> refresh(String refreshToken) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (refreshToken.isEmpty || refreshToken == 'expired_token') {
      throw Exception('Refresh token hilang atau sudah kedaluwarsa');
    }

    return 'mock-access-renewed-${DateTime.now().millisecondsSinceEpoch}';
  }
}
