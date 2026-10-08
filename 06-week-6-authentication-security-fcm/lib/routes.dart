import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'pages/announcement_page.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'providers/auth_provider.dart';

/// Konstanta rute navigasi aplikasi
class AppRoutes {
  static const String login = '/login';
  static const String home = '/';
  static const String announcement = '/pengumuman/:id';

  static String announcementPath(String id) => '/pengumuman/$id';
}

/// Fungsi murni untuk mengekstrak dan menormalisasi path rute dari payload data FCM.
/// Memastikan path selalu berawalan '/' dan menangani default jika route tidak ditemukan.
String routeFromMessage(Map<String, dynamic> data) {
  final rawRoute = data['route']?.toString() ?? '/';
  if (rawRoute.isEmpty) return '/';
  return rawRoute.startsWith('/') ? rawRoute : '/$rawRoute';
}

/// Provider GoRouter yang terhubung dengan Riverpod untuk proteksi guard route (Authentication Guard)
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.home,
    redirect: (BuildContext context, GoRouterState state) {
      // Tunggu hingga status autentikasi selesai dimuat (jika masih initial loading)
      if (authState.isLoading) return null;

      final bool isLoggedIn = authState.value ?? false;
      final bool isGoingToLogin = state.matchedLocation == AppRoutes.login;

      // Jika belum login dan mencoba mengakses rute terproteksi -> alihkan ke /login
      if (!isLoggedIn && !isGoingToLogin) {
        return AppRoutes.login;
      }

      // Jika sudah login dan masih di halaman /login -> alihkan ke halaman utama /
      if (isLoggedIn && isGoingToLogin) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.announcement,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '1';
          return AnnouncementPage(id: id);
        },
      ),
    ],
  );
});
