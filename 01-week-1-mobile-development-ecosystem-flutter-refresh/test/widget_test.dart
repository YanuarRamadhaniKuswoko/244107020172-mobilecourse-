import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week1_mobile_refresh/main.dart';

void main() {
  testWidgets('Profil Mahasiswa UI render test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that AppBar title is rendered.
    expect(find.text('Profil Mahasiswa'), findsOneWidget);

    // Verify that student name is rendered.
    expect(find.text('Yanuar Ramadhani Kuswoko'), findsOneWidget);

    // Verify that student NIM is rendered.
    expect(find.text('244107020176'), findsOneWidget);

    // Verify that course & week info is rendered.
    expect(find.text('Pemrograman Mobile — Minggu 1'), findsOneWidget);

    // Verify that additional information is rendered.
    expect(find.text('TI-2D / 25'), findsOneWidget);
    expect(find.text('D-IV Teknik Informatika'), findsOneWidget);
    expect(find.text('Politeknik Negeri Malang'), findsOneWidget);

    // Verify icons are present.
    expect(find.byIcon(Icons.school), findsOneWidget);
    expect(find.byIcon(Icons.badge), findsOneWidget);
    expect(find.byIcon(Icons.class_), findsOneWidget);
  });
}
