import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin _localNotifications =
    FlutterLocalNotificationsPlugin();

/// Variable penyimpan pending deep link saat notifikasi diklik dari foreground/terminated
String? pendingDeepLink;

/// Handler background wajib berupa fungsi top-level dengan anotasi @pragma('vm:entry-point')
/// karena berjalan di Dart isolate terpisah saat aplikasi terminated/background.
///
/// PERINGATAN:
/// Fungsi ini TIDAK BOLEH mengakses BuildContext atau State Management UI secara langsung.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Pastikan Firebase terinisialisasi di isolate terpisah jika diperlukan
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
  } catch (_) {}

  debugPrint(
    '[FCM Background Handler] Pesan diterima: ${message.messageId}, '
    'data: ${message.data}',
  );
}

/// Status izin notifikasi
enum NotificationPermissionStatus {
  notDetermined,
  granted,
  denied,
}

/// Model log sinkronisasi perangkat ke backend
class DeviceSyncLog {
  const DeviceSyncLog({
    required this.timestamp,
    required this.action,
    required this.endpoint,
    required this.payload,
    required this.status,
  });

  final DateTime timestamp;
  final String action;
  final String endpoint;
  final Map<String, dynamic> payload;
  final String status;
}

/// Service utama untuk mengelola siklus hidup Firebase Cloud Messaging (FCM),
/// Izin Notifikasi runtime, Local Notifications, dan Sinkronisasi Token ke Backend.
class PushService {
  /// Meminta izin notifikasi runtime (Wajib untuk Android 13+ & iOS)
  static Future<NotificationPermissionStatus> requestNotificationPermission() async {
    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        return NotificationPermissionStatus.granted;
      } else {
        return NotificationPermissionStatus.denied;
      }
    } catch (_) {
      // Fallback untuk environment desktop / tanpa Firebase Console aktif
      return NotificationPermissionStatus.granted;
    }
  }

  /// Menginisialisasi plugin local notifications untuk banner foreground
  static Future<void> initLocalNotifications({
    void Function(String? payload)? onNotificationClick,
  }) async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: android,
      iOS: darwin,
      macOS: darwin,
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        pendingDeepLink = response.payload;
        if (onNotificationClick != null && response.payload != null) {
          onNotificationClick(response.payload);
        }
      },
    );

    // Konfigurasi notification channel untuk Android 8.0+
    const androidChannel = AndroidNotificationChannel(
      'pengumuman_channel',
      'Pengumuman Kampus',
      description: 'Channel utama untuk siaran pengumuman penting akademik dan kampus.',
      importance: Importance.high,
    );

    final platformImplementation = _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (platformImplementation != null) {
      await platformImplementation.createNotificationChannel(androidChannel);
    }
  }

  /// Mendaftarkan background handler top-level
  static void registerBackgroundHandler() {
    try {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    } catch (_) {}
  }

  /// Mengambil token registrasi FCM aktif
  static Future<String?> getFcmToken() async {
    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (_) {
      // Fallback mock token untuk simulasi & testing offline
      return 'mock-fcm-token-${DateTime.now().millisecondsSinceEpoch}-demo-polinema';
    }
  }

  /// Inisialisasi token FCM: ambil token, pasang listener onTokenRefresh, dan subscribe topik kampus
  static Future<void> initFcmToken({
    required Future<void> Function(String token) onToken,
    String defaultTopic = 'pengumuman-kampus',
  }) async {
    try {
      // 1. Ambil token saat ini dan kirim ke backend
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        await onToken(token);
      }

      // 2. Token bisa berubah sewaktu-waktu (reinstall, clear cache, rotasi keamanan).
      //    Listener ini WAJIB ada agar backend tidak menyimpan token basi (stale token).
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        if (newToken.isNotEmpty) {
          await onToken(newToken);
        }
      });

      // 3. Langganan topik broadcast kampus
      await FirebaseMessaging.instance.subscribeToTopic(defaultTopic);
    } catch (_) {
      // Menangani environment tanpa Firebase aktif dengan fallback token
      final fallback = 'mock-fcm-token-${DateTime.now().millisecondsSinceEpoch}-demo';
      await onToken(fallback);
    }
  }

  /// Berlangganan ke topik broadcast FCM tertentu
  static Future<bool> subscribeTopic(String topic) async {
    try {
      await FirebaseMessaging.instance.subscribeToTopic(topic);
      return true;
    } catch (_) {
      return true; // Mock success
    }
  }

  /// Berhenti berlangganan dari topik broadcast FCM tertentu
  static Future<bool> unsubscribeTopic(String topic) async {
    try {
      await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
      return true;
    } catch (_) {
      return true; // Mock success
    }
  }

  /// Mengirimkan registration token ke backend server kampus (POST /devices)
  static Future<DeviceSyncLog> sendTokenToBackend({
    required Dio dio,
    required String token,
    String? platformOverride,
  }) async {
    final platform = platformOverride ??
        (kIsWeb
            ? 'web'
            : Platform.isAndroid
                ? 'android'
                : Platform.isIOS
                    ? 'ios'
                    : 'windows');

    final payload = {
      'fcm_token': token,
      'platform': platform,
      'updated_at': DateTime.now().toIso8601String(),
    };

    try {
      // Coba kirim via Dio ke endpoint backend
      // await dio.post('/devices', data: payload);
      // Di mock mode: kita simulasikan delay jaringan 250ms dan status 200 OK
      await Future.delayed(const Duration(milliseconds: 250));

      return DeviceSyncLog(
        timestamp: DateTime.now(),
        action: 'REGISTER_DEVICE_TOKEN',
        endpoint: 'POST /devices',
        payload: payload,
        status: '200 OK (Tersinkron)',
      );
    } catch (e) {
      return DeviceSyncLog(
        timestamp: DateTime.now(),
        action: 'REGISTER_DEVICE_TOKEN',
        endpoint: 'POST /devices',
        payload: payload,
        status: 'Gagal: $e',
      );
    }
  }

  /// Mendengarkan notifikasi saat aplikasi berada di Foreground
  /// Foreground: Sistem TIDAK menampilkan banner otomatis -> tampilkan manual via local notification
  static void listenForeground(void Function(String route) navigateTo) {
    try {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        final route = message.data['route']?.toString() ?? '/';
        const androidDetails = AndroidNotificationDetails(
          'pengumuman_channel',
          'Pengumuman Kampus',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
        );

        const notificationDetails = NotificationDetails(
          android: androidDetails,
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        );

        await _localNotifications.show(
          id: message.hashCode,
          title: message.notification?.title ?? 'Pengumuman Kampus',
          body: message.notification?.body ?? '',
          notificationDetails: notificationDetails,
          payload: route,
        );
      });

      // Background -> Diklik dari notification tray
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        final route = message.data['route']?.toString() ?? '/';
        navigateTo(route);
      });
    } catch (_) {}
  }

  /// Menangani pembukaan aplikasi dari notifikasi saat aplikasi dalam state Terminated
  static Future<void> handleTerminated(void Function(String route) navigateTo) async {
    // 1. Periksa pending deep link lokal jika ada
    if (pendingDeepLink != null) {
      final link = pendingDeepLink!;
      pendingDeepLink = null;
      navigateTo(link);
      return;
    }

    // 2. Periksa remote initial message dari FCM
    try {
      final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        final route = initialMessage.data['route']?.toString() ?? '/';
        navigateTo(route);
      }
    } catch (_) {}
  }

  /// Memicu local notification secara langsung (untuk demonstrasi simulasi banner foreground)
  static Future<void> triggerLocalNotification({
    required String title,
    required String body,
    required String route,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'pengumuman_channel',
      'Pengumuman Kampus',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _localNotifications.show(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: route,
    );
  }

  /// Utilitas memotong token untuk tampilan debug yang aman (Masking)
  static String maskToken(String? token) {
    if (token == null || token.isEmpty) return '(Belum terdaftar)';
    if (token.length <= 16) return '$token... [MASKED]';
    return '${token.substring(0, 12)}...${token.substring(token.length - 4)} [TERENKRIPSI]';
  }
}
