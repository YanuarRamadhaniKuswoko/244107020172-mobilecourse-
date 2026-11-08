import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:ai_feature_integration/ai/ai_service.dart';

class FakeSecureStorage extends FlutterSecureStorage {
  final Map<String, String> _data = {};

  FakeSecureStorage([Map<String, String>? initialData]) {
    if (initialData != null) _data.addAll(initialData);
  }

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async =>
      _data[key];

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value != null) {
      _data[key] = value;
    } else {
      _data.remove(key);
    }
  }

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _data.remove(key);
  }

  @override
  Future<void> deleteAll({
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _data.clear();
  }

  @override
  Future<Map<String, String>> readAll({
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async =>
      Map.from(_data);

  @override
  Future<bool> containsKey({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async =>
      _data.containsKey(key);
}

void main() {
  group('AiService Tests', () {
    test('Throws exception when API key is missing', () async {
      final storage = FakeSecureStorage();
      final service = AiService(storage: storage);

      expect(
        () => service.ask('Halo apa kabar?'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('API key tidak tersedia'),
          ),
        ),
      );
    });

    test('ask() returns AI response text on HTTP 200', () async {
      final storage = FakeSecureStorage({'ai_api_key': 'test-secret-key'});
      final mockClient = MockClient((request) async {
        expect(request.url.queryParameters['key'], 'test-secret-key');
        expect(request.headers['Content-Type'], 'application/json');

        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['contents'][0]['parts'][0]['text'], 'Halo Gemini');

        return http.Response(
          jsonEncode({
            'candidates': [
              {
                'content': {
                  'parts': [
                    {'text': 'Halo! Saya asisten kampus siap membantu.'}
                  ]
                }
              }
            ]
          }),
          200,
        );
      });

      final service = AiService(storage: storage, client: mockClient);
      final reply = await service.ask('Halo Gemini');

      expect(reply, 'Halo! Saya asisten kampus siap membantu.');
    });

    test('ask() throws exception on HTTP error (e.g. 500)', () async {
      final storage = FakeSecureStorage({'ai_api_key': 'test-secret-key'});
      final mockClient = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      final service = AiService(storage: storage, client: mockClient);

      expect(
        () => service.ask('Halo Gemini'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Gagal memanggil AI API: 500'),
          ),
        ),
      );
    });

    test('saveApiKey() and getApiKey() securely store and retrieve key',
        () async {
      final storage = FakeSecureStorage();
      final service = AiService(storage: storage);

      expect(await service.getApiKey(), isNull);
      await service.saveApiKey('my-gemini-token-123');
      expect(await service.getApiKey(), 'my-gemini-token-123');
    });
  });
}

