import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:responsive_dashboard/main.dart';

void main() {
  testWidgets('Dashboard satu kolom di layar sempit', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const DashboardApp());
    await tester.pumpAndSettle();

    // Verifikasi lebar kartu pada layar sempit (1 kolom)
    final cards = find.byType(Card);
    expect(cards, findsWidgets);

    final width = tester.getSize(cards.first).width;
    expect(width, lessThan(700));
  });

  testWidgets('Dashboard dua kolom di layar lebar', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const DashboardApp());
    await tester.pumpAndSettle();

    // Verifikasi lebar kartu pada layar lebar (2 kolom)
    final cards = find.byType(Card);
    expect(cards, findsWidgets);

    final width = tester.getSize(cards.first).width;
    expect(width, greaterThan(450));
  });

  testWidgets('Toggle tema dengan CupertinoSwitch beralih antara light dan dark mode', (tester) async {
    await tester.pumpWidget(const DashboardApp());
    await tester.pumpAndSettle();

    // Cari icon light mode default
    expect(find.byIcon(Icons.light_mode), findsOneWidget);

    // Temukan CupertinoSwitch dan tap
    final switchFinder = find.byType(CupertinoSwitch);
    expect(switchFinder, findsOneWidget);
    await tester.tap(switchFinder);
    await tester.pumpAndSettle();

    // Pastikan setelah di-tap, icon berubah menjadi dark_mode
    expect(find.byIcon(Icons.dark_mode), findsOneWidget);
  });

  testWidgets('Header profil dan InfoCard menampilkan identitas dan data akademik', (tester) async {
    await tester.pumpWidget(const DashboardApp());
    await tester.pumpAndSettle();

    // Verifikasi elemen Header Profil
    expect(find.text('Yanuar Ramadhani Kuswoko'), findsOneWidget);
    expect(find.textContaining('244107020176'), findsOneWidget);
    expect(find.textContaining('TI-2D / 25'), findsOneWidget);

    // Verifikasi kartu informasi akademik
    expect(find.text('Assignments'), findsOneWidget);
    expect(find.text('Attendance'), findsOneWidget);
    expect(find.text('Portfolio'), findsOneWidget);
    expect(find.text('Current week'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
    expect(find.text('92%'), findsOneWidget);
    expect(find.text('Ready'), findsOneWidget);
    expect(find.text('02'), findsOneWidget);
  });
}
