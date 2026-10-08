import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../messaging/push_service.dart';
import 'auth_provider.dart';

/// State model untuk manajemen Push Notification & Token Lifecycle
class FcmState {
  const FcmState({
    this.token,
    this.permissionStatus = NotificationPermissionStatus.notDetermined,
    this.isSubscribedTopic = true,
    this.isLoading = false,
    this.isSyncing = false,
    this.syncLogs = const [],
  });

  final String? token;
  final NotificationPermissionStatus permissionStatus;
  final bool isSubscribedTopic;
  final bool isLoading;
  final bool isSyncing;
  final List<DeviceSyncLog> syncLogs;

  String get maskedToken => PushService.maskToken(token);

  FcmState copyWith({
    String? token,
    NotificationPermissionStatus? permissionStatus,
    bool? isSubscribedTopic,
    bool? isLoading,
    bool? isSyncing,
    List<DeviceSyncLog>? syncLogs,
  }) {
    return FcmState(
      token: token ?? this.token,
      permissionStatus: permissionStatus ?? this.permissionStatus,
      isSubscribedTopic: isSubscribedTopic ?? this.isSubscribedTopic,
      isLoading: isLoading ?? this.isLoading,
      isSyncing: isSyncing ?? this.isSyncing,
      syncLogs: syncLogs ?? this.syncLogs,
    );
  }
}

/// Notifier untuk mengelola alur FCM, listener onTokenRefresh, dan izin notifikasi
final fcmProvider = NotifierProvider<FcmNotifier, FcmState>(FcmNotifier.new);

class FcmNotifier extends Notifier<FcmState> {
  @override
  FcmState build() {
    return const FcmState();
  }

  /// Inisialisasi awal FCM dan sinkronisasi token pertama ke backend
  Future<void> initPushService() async {
    state = state.copyWith(isLoading: true);

    try {
      // 1. Minta izin notifikasi runtime
      final permission = await PushService.requestNotificationPermission();

      // 2. Ambil token FCM awal
      final initialToken = await PushService.getFcmToken();

      // 3. Kirimkan token ke backend server kampus (POST /devices)
      final dio = ref.read(apiClientProvider);
      DeviceSyncLog? initialLog;
      if (initialToken != null) {
        initialLog = await PushService.sendTokenToBackend(
          dio: dio,
          token: initialToken,
        );
      }

      state = state.copyWith(
        token: initialToken,
        permissionStatus: permission,
        isLoading: false,
        isSubscribedTopic: true,
        syncLogs: initialLog != null ? [initialLog, ...state.syncLogs] : state.syncLogs,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Meminta izin notifikasi ulang secara interaktif
  Future<void> requestPermission() async {
    final status = await PushService.requestNotificationPermission();
    state = state.copyWith(permissionStatus: status);
  }

  /// Simulasi peristiwa onTokenRefresh (rotasi token / reinstall aplikasi)
  /// Membuktikan bahwa token baru dikirim otomatis ke backend POST /devices
  Future<void> simulateTokenRefresh() async {
    state = state.copyWith(isSyncing: true);

    final newToken =
        'fcm-token-rotasi-${DateTime.now().millisecondsSinceEpoch}-rotated-key';

    final dio = ref.read(apiClientProvider);
    final log = await PushService.sendTokenToBackend(
      dio: dio,
      token: newToken,
    );

    state = state.copyWith(
      token: newToken,
      isSyncing: false,
      syncLogs: [log, ...state.syncLogs],
    );
  }

  /// Mengubah status langganan topik 'pengumuman-kampus'
  Future<void> toggleTopicSubscription() async {
    final nextStatus = !state.isSubscribedTopic;
    if (nextStatus) {
      await PushService.subscribeTopic('pengumuman-kampus');
    } else {
      await PushService.unsubscribeTopic('pengumuman-kampus');
    }

    state = state.copyWith(isSubscribedTopic: nextStatus);
  }
}
