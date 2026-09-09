import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week3_navigation_state/main.dart';

void main() {
  testWidgets('menambah tugas baru ke daftar ToDo', (tester) async {
    // Build the app within ProviderScope
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify initial empty state
    expect(find.text('Belum ada tugas'), findsOneWidget);

    // Tap FloatingActionButton to open the dialog
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Enter task name in TextField
    expect(find.byType(TextField), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Kerjakan PR minggu 3');
    await tester.pump();

    // Tap 'Tambah' button
    await tester.tap(find.text('Tambah'));
    await tester.pumpAndSettle();

    // Verify the newly created task appears in the list
    expect(find.text('Kerjakan PR minggu 3'), findsOneWidget);
  });

  testWidgets('toggle status checkbox dan hapus tugas', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Add a task
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Belajar Testing Flutter');
    await tester.tap(find.text('Tambah'));
    await tester.pumpAndSettle();

    expect(find.text('Belajar Testing Flutter'), findsOneWidget);

    // Toggle checkbox
    final checkboxFinder = find.byType(Checkbox);
    expect(checkboxFinder, findsOneWidget);
    await tester.tap(checkboxFinder);
    await tester.pumpAndSettle();

    // Delete the task
    final deleteIconFinder = find.byIcon(Icons.delete_outline);
    expect(deleteIconFinder, findsOneWidget);
    await tester.tap(deleteIconFinder);
    await tester.pumpAndSettle();

    // Verify task is removed
    expect(find.text('Belajar Testing Flutter'), findsNothing);
    expect(find.text('Belum ada tugas'), findsOneWidget);
  });

  testWidgets('berpindah tab antara Daftar Tugas dan Statistik melalui NavigationBar', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Initially on ToDo page
    expect(find.text('ToDo Riverpod'), findsOneWidget);

    // Tap 'Statistik' destination in NavigationBar
    await tester.tap(find.text('Statistik'));
    await tester.pumpAndSettle();

    // Verify Stats page is displayed
    expect(find.text('Statistik & Analitik'), findsOneWidget);

    // Switch back to Daftar Tugas
    await tester.tap(find.text('Daftar Tugas'));
    await tester.pumpAndSettle();

    expect(find.text('ToDo Riverpod'), findsOneWidget);
  });
}
