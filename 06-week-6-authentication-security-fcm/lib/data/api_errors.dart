import 'package:dio/dio.dart';

/// Utilitas untuk memetakan error DioException / exception umum menjadi pesan
/// yang ramah dan mudah dipahami oleh pengguna.
class ApiErrorMapper {
  static String toUserFriendlyMessage(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Koneksi ke server timeout. Silakan periksa jaringan internet Anda.';
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          if (statusCode == 401) {
            return 'Sesi Anda telah kedaluwarsa (401 Unauthorized). Silakan masuk kembali.';
          } else if (statusCode == 403) {
            return 'Anda tidak memiliki akses ke sumber daya ini (403 Forbidden).';
          } else if (statusCode == 404) {
            return 'Data yang dicari tidak ditemukan di server (404 Not Found).';
          } else if (statusCode != null && statusCode >= 500) {
            return 'Terjadi gangguan pada server kampus ($statusCode). Silakan coba lagi nanti.';
          }
          return 'Terjadi kesalahan respons server (${statusCode ?? 'Unknown'}).';
        case DioExceptionType.connectionError:
          return 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
        case DioExceptionType.cancel:
          return 'Permintaan dibatalkan.';
        default:
          return error.message ?? 'Terjadi kesalahan jaringan yang tidak diketahui.';
      }
    }

    if (error is Exception) {
      final msg = error.toString();
      if (msg.startsWith('Exception: ')) {
        return msg.substring(11);
      }
      return msg;
    }

    return error?.toString() ?? 'Terjadi kesalahan sistem.';
  }
}
