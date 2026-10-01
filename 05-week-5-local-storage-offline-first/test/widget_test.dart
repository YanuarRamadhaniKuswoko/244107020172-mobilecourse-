import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week5_offline_notes/data/local/note.dart';
import 'package:week5_offline_notes/widgets/note_tile.dart';

void main() {
  testWidgets('NoteTile displays title and dirty badge properly',
      (WidgetTester tester) async {
    final dirtyNote = Note(
      id: 1,
      title: 'Catatan Belum Sinkron',
      body: 'Ini isi catatan yang kotor',
      updatedAt: DateTime(2026, 10, 1, 10, 0),
      dirty: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NoteTile(
            note: dirtyNote,
            onTap: () {},
            onDelete: () {},
          ),
        ),
      ),
    );

    expect(find.text('Catatan Belum Sinkron'), findsOneWidget);
    expect(find.text('Ini isi catatan yang kotor'), findsOneWidget);
    expect(find.text('Belum Sinkron'), findsOneWidget);
  });

  testWidgets('NoteTile displays clean synced badge when dirty is false',
      (WidgetTester tester) async {
    final cleanNote = Note(
      id: 2,
      title: 'Catatan Bersih',
      body: 'Sudah tersinkron ke cloud',
      updatedAt: DateTime(2026, 10, 1, 12, 0),
      dirty: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NoteTile(
            note: cleanNote,
            onTap: () {},
            onDelete: () {},
          ),
        ),
      ),
    );

    expect(find.text('Catatan Bersih'), findsOneWidget);
    expect(find.text('Tersinkron'), findsOneWidget);
  });
}
