import 'package:campus_notify/messaging/push_service.dart';
import 'package:campus_notify/routes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Testing Praktikum 3: Matriks Pengujian 3 State Aplikasi & FCM Payload', () {
    test('Ekstraksi route dari remote data payload gabungan', () {
      final payload = {
        'route': '/pengumuman/3',
        'id': '3',
        'type': 'broadcast',
      };

      expect(routeFromMessage(payload), '/pengumuman/3');
      expect(payload['id'], '3');
    });

    test('Ekstraksi route menormalisasi rute tanpa leading slash', () {
      final payload = {'route': 'pengumuman/99'};
      expect(routeFromMessage(payload), '/pengumuman/99');
    });

    test('Ekstraksi route mengembalikan default root "/" jika route kosong atau null', () {
      expect(routeFromMessage({}), '/');
      expect(routeFromMessage({'other_data': '123'}), '/');
      expect(routeFromMessage({'route': ''}), '/');
    });

    test('Handling pending deep link pada startup state Terminated', () async {
      // Set pending deep link
      pendingDeepLink = '/pengumuman/3';

      String? resolvedRoute;
      await PushService.handleTerminated((route) {
        resolvedRoute = route;
      });

      expect(resolvedRoute, '/pengumuman/3');
      expect(pendingDeepLink, isNull); // Pastikan sudah dibersihkan setelah diarahkan
    });
  });
}
