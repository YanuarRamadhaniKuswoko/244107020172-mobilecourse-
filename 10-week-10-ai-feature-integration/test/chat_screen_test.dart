import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_feature_integration/ai/ai_service.dart';
import 'package:ai_feature_integration/features/chat_screen.dart';
import 'ai_service_test.dart';

class MockAiService extends AiService {
  final Future<String> Function(String)? onAsk;

  MockAiService({this.onAsk, FakeSecureStorage? storage})
      : super(storage: storage ?? FakeSecureStorage({'ai_api_key': 'test-key'}));

  @override
  Future<String> ask(String question) async {
    if (onAsk != null) {
      return await onAsk!(question);
    }
    return 'Jawaban uji coba dari asisten AI.';
  }
}

void main() {
  group('ChatScreen Widget Tests', () {
    testWidgets('Renders initial chat elements correctly', (tester) async {
      final mockService = MockAiService();

      await tester.pumpWidget(
        MaterialApp(
          home: ChatScreen(aiService: mockService),
        ),
      );

      // Verify AppBar and Action
      expect(find.text('AI Campus Assistant'), findsOneWidget);
      expect(find.byIcon(Icons.key), findsOneWidget);

      // Verify privacy banner
      expect(
        find.text(
          'Privasi terjaga: Jangan menyertakan NIK, password, atau nomor HP.',
        ),
        findsOneWidget,
      );

      // Verify greeting bubble
      expect(
        find.text(
          'Halo! Saya asisten AI kampus. Ada yang bisa saya bantu hari ini?',
        ),
        findsOneWidget,
      );

      // Verify input and send button
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.send), findsOneWidget);
    });

    testWidgets('Blocks sensitive data (NIK) and shows privacy warning SnackBar',
        (tester) async {
      final mockService = MockAiService();

      await tester.pumpWidget(
        MaterialApp(
          home: ChatScreen(aiService: mockService),
        ),
      );

      // Enter sensitive 16 digit NIK
      await tester.enterText(
        find.byType(TextField),
        'Halo ini NIK saya 3507112233445566 tolong cek nilai',
      );
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();

      // Verify warning SnackBar is displayed
      expect(
        find.text(
          'Peringatan Privasi: Pesan mengandung NIK/Nomor Telepon sensitif. Harap gunakan data anonim.',
        ),
        findsOneWidget,
      );

      // Verify user message was NOT added to chat list
      expect(
        find.descendant(
          of: find.byType(ListView),
          matching: find.text('Halo ini NIK saya 3507112233445566 tolong cek nilai'),
        ),
        findsNothing,
      );
    });

    testWidgets('Sends question and streams AI response bubble',
        (tester) async {
      final mockService = MockAiService(
        onAsk: (q) async => 'Jadwal kuliah hari Senin adalah Pemrograman Mobile.',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ChatScreen(aiService: mockService),
        ),
      );

      // Type question and send
      await tester.enterText(
        find.byType(TextField),
        'Apa jadwal kuliah hari Senin?',
      );
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();

      // User bubble appears immediately
      expect(find.text('Apa jadwal kuliah hari Senin?'), findsOneWidget);

      // Pump through streaming animation delays
      await tester.pumpAndSettle();

      // AI response bubble rendered
      expect(
        find.text('Jadwal kuliah hari Senin adalah Pemrograman Mobile.'),
        findsOneWidget,
      );
    });

    testWidgets('Displays fallback dialog when AI service throws error',
        (tester) async {
      final mockService = MockAiService(
        onAsk: (q) async => throw Exception('API Rate limit reached'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ChatScreen(aiService: mockService),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Kapan KRS dibuka?');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      // Fallback dialog from Jobsheet
      expect(find.text('Layanan AI Sibuk'), findsOneWidget);
      expect(
        find.text('Coba lagi nanti atau gunakan mode offline.'),
        findsOneWidget,
      );
      expect(find.text('Tutup'), findsOneWidget);
    });
  });
}
