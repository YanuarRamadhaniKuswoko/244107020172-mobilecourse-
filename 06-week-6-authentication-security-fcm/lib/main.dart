import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'messaging/push_service.dart';
import 'routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase (dengan fallback jika belum dikonfigurasi)
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Berjalan dalam mock mode jika Firebase belum dikonfigurasi
  }

  // Inisialisasi background handler FCM top-level
  PushService.registerBackgroundHandler();

  // Inisialisasi local notifications untuk banner foreground & deep link click
  await PushService.initLocalNotifications();

  runApp(
    const ProviderScope(
      child: CampusNotifyApp(),
    ),
  );
}

class CampusNotifyApp extends ConsumerStatefulWidget {
  const CampusNotifyApp({super.key});

  @override
  ConsumerState<CampusNotifyApp> createState() => _CampusNotifyAppState();
}

class _CampusNotifyAppState extends ConsumerState<CampusNotifyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final router = ref.read(routerProvider);

      // Tangani pesan terminated (bila aplikasi dibuka dari notifikasi saat mati)
      PushService.handleTerminated((route) {
        if (route.isNotEmpty) {
          router.push(route);
        }
      });

      // Tangani pesan foreground & background saat aplikasi aktif
      PushService.listenForeground((route) {
        if (route.isNotEmpty) {
          router.push(route);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Campus Notify - Polinema',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3A8A), // Navy Blue Polinema
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
        ),
        cardTheme: const CardThemeData(
          elevation: 1.5,
          margin: EdgeInsets.zero,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3B82F6),
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
        ),
      ),
      routerConfig: router,
    );
  }
}
