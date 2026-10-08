import 'package:campus_notify/pages/announcement_page.dart';
import 'package:campus_notify/pages/login_page.dart';
import 'package:campus_notify/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('LoginPage renders form, branding, and input fields', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith(() => _MockLoggedOutAuthNotifier()),
        ],
        child: const MaterialApp(
          home: LoginPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verifikasi bahwa elemen branding dan form login tampil
    expect(find.text('Campus Notify'), findsOneWidget);
    expect(find.text('Masuk ke Akun Anda'), findsOneWidget);
    expect(find.text('Email Mahasiswa / Kampus'), findsOneWidget);
    expect(find.text('Kata Sandi'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
  });

  testWidgets('AnnouncementPage renders correctly with parameter ID', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AnnouncementPage(id: '3'),
      ),
    );

    expect(find.text('Detail Pengumuman'), findsOneWidget);
    expect(find.text('ID: 3'), findsOneWidget);
    expect(find.text('Kelas Mobile Pindah ke Ruang A2 Jam 13.00'), findsOneWidget);
  });
}

class _MockLoggedOutAuthNotifier extends AuthNotifier {
  @override
  Future<bool> build() async {
    return false;
  }
}
