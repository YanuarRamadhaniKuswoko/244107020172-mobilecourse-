import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AiService {
  final FlutterSecureStorage _storage;
  final http.Client? _client;
  final String _apiUrl;

  AiService({
    FlutterSecureStorage? storage,
    this._client,
    String? apiUrl,
  })  : _storage = storage ?? const FlutterSecureStorage(),
        _apiUrl = apiUrl ??
            'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';

  Future<String> ask(String question) async {
    final apiKey = await _storage.read(key: 'ai_api_key');
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('API key tidak tersedia. Silakan atur di pengaturan.');
    }

    final uri = Uri.parse('$_apiUrl?key=$apiKey');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': question}
          ]
        }
      ]
    });

    final response = _client != null
        ? await _client.post(uri, headers: headers, body: body)
        : await http.post(uri, headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'];
    } else {
      throw Exception('Gagal memanggil AI API: ${response.statusCode}');
    }
  }

  Future<void> saveApiKey(String key) async {
    await _storage.write(key: 'ai_api_key', value: key);
  }

  Future<String?> getApiKey() async {
    return await _storage.read(key: 'ai_api_key');
  }
}
