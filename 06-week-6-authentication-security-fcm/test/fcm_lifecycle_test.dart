import 'package:campus_notify/data/api_client.dart';
import 'package:campus_notify/data/auth_repository.dart';
import 'package:campus_notify/data/token_store.dart';
import 'package:campus_notify/messaging/push_service.dart';
import 'package:campus_notify/providers/push_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Testing Praktikum 2: FCM, Permission, dan Token Lifecycle', () {
    test('PushService.maskToken memotong token dengan aman (tidak mencetak penuh)', () {
      expect(PushService.maskToken(null), '(Belum terdaftar)');
      expect(PushService.maskToken(''), '(Belum terdaftar)');

      const sampleToken = 'c7K8L1mN0pQ9rS8tU7vW6xY5zA4bC3dE2fG1';
      final masked = PushService.maskToken(sampleToken);

      // Token terpotong: berisi 12 karakter awal dan penanda terenkripsi
      expect(masked.startsWith('c7K8L1mN0pQ9...'), isTrue);
      expect(masked.contains('[TERENKRIPSI]'), isTrue);
      // Memastikan string token lengkap TIDAK muncul secara utuh
      expect(masked == sampleToken, isFalse);
    });

    test('PushService.sendTokenToBackend menyusun payload POST /devices dengan benar', () async {
      final dio = buildApiClient(TokenStore(), AuthRepository());
      final log = await PushService.sendTokenToBackend(
        dio: dio,
        token: 'sample-token-1234567890',
        platformOverride: 'android',
      );

      expect(log.endpoint, 'POST /devices');
      expect(log.payload['fcm_token'], 'sample-token-1234567890');
      expect(log.payload['platform'], 'android');
      expect(log.payload['updated_at'], isNotNull);
      expect(log.status.contains('200 OK'), isTrue);
    });

    test('FcmNotifier dapat melakukan simulasi onTokenRefresh dan mencatat riwayat sync', () async {
      final container = ProviderContainer();

      final notifier = container.read(fcmProvider.notifier);
      expect(container.read(fcmProvider).syncLogs.isEmpty, isTrue);

      await notifier.simulateTokenRefresh();

      final state = container.read(fcmProvider);
      expect(state.token, isNotNull);
      expect(state.token!.startsWith('fcm-token-rotasi-'), isTrue);
      expect(state.syncLogs.length, 1);
      expect(state.syncLogs.first.endpoint, 'POST /devices');
    });

    test('FcmNotifier dapat mengaktifkan dan menonaktifkan langganan topik', () async {
      final container = ProviderContainer();
      final notifier = container.read(fcmProvider.notifier);

      expect(container.read(fcmProvider).isSubscribedTopic, isTrue);

      await notifier.toggleTopicSubscription();
      expect(container.read(fcmProvider).isSubscribedTopic, isFalse);

      await notifier.toggleTopicSubscription();
      expect(container.read(fcmProvider).isSubscribedTopic, isTrue);
    });
  });
}
