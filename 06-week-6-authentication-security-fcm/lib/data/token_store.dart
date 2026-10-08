import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Pintu tunggal untuk menyimpan, membaca, dan menghapus Access Token & Refresh Token
/// secara aman menggunakan Platform Keystore (Android) / Keychain (iOS).
///
/// PERINGATAN KEAMANAN:
/// Jangan pernah menyimpan refresh token di SharedPreferences karena tidak terenkripsi.
class TokenStore {
  TokenStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  /// Menyimpan pasangan access token dan refresh token ke secure storage.
  Future<void> save({required String access, required String refresh}) async {
    await _storage.write(key: _accessKey, value: access);
    await _storage.write(key: _refreshKey, value: refresh);
  }

  /// Membaca access token aktif dari secure storage.
  Future<String?> readAccess() => _storage.read(key: _accessKey);

  /// Membaca refresh token aktif dari secure storage.
  Future<String?> readRefresh() => _storage.read(key: _refreshKey);

  /// Menghapus seluruh token dari secure storage (digunakan saat logout / token mati).
  Future<void> clear() => _storage.deleteAll();
}
