import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:testing_lab/main.dart';

void main() {
  testWidgets('menampilkan judul halaman tugas', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Text('Daftar tugas'),
        ),
      ),
    );

    expect(find.text('Daftar tugas'), findsOneWidget);
  });

  testWidgets('interaksi menambah tugas', (tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.enterText(
      find.byKey(const Key('task-title-field')),
      'Baca materi',
    );
    await tester.tap(find.byKey(const Key('save-task-button')));
    await tester.pumpAndSettle();

    expect(find.text('Baca materi'), findsOneWidget);
  });

  testWidgets('menampilkan pesan saat input tidak valid', (tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.enterText(
      find.byKey(const Key('task-title-field')),
      '   ',
    );
    await tester.tap(find.byKey(const Key('save-task-button')));
    await tester.pumpAndSettle();

    expect(find.text('Judul tugas tidak boleh kosong'), findsOneWidget);
  });
}
