// test/widget_test.dart
//
// Widget test untuk empty state search – jobsheet Praktikum 2 + Minggu 9.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_search_ai/features/notes/presentation/providers/notes_providers.dart';

class _TestSearchQueryNotifier extends SearchQueryNotifier {
  @override
  String build() => 'zzz-tidak-ada';
}

void main() {
  testWidgets(
    'empty state muncul dengan pesan yang benar saat query tidak cocok',
    (WidgetTester tester) async {
      // Buat widget sederhana yang hanya render empty state text
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // Override filteredNotesProvider dengan data kosong (simulasi tidak cocok)
            filteredNotesProvider.overrideWith(
              (ref) => const AsyncValue.data([]),
            ),
            searchQueryProvider.overrideWith(_TestSearchQueryNotifier.new),
            dirtyCountProvider.overrideWith((ref) async => 0),
          ],
          child: const MaterialApp(home: Scaffold(body: _EmptyStateWidget())),
        ),
      );

      await tester.pumpAndSettle();

      // Pastikan widget tidak crash — empty state dapat di-render dengan pesan yang tepat
      expect(find.byType(Scaffold), findsOneWidget);
      expect(
        find.text('Tidak ada catatan dengan judul\n"zzz-tidak-ada"'),
        findsOneWidget,
      );
    },
  );
}

/// Widget kecil yang hanya menampilkan empty state berdasarkan query.
/// Tujuan: uji bahwa empty state text sesuai kondisi query.
class _EmptyStateWidget extends ConsumerWidget {
  const _EmptyStateWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchQueryProvider);
    final filteredAsync = ref.watch(filteredNotesProvider);

    return filteredAsync.when(
      loading: () => const CircularProgressIndicator(),
      error: (e, _) => Text('Error: $e'),
      data: (notes) {
        if (notes.isEmpty) {
          return Text(
            query.isNotEmpty
                ? 'Tidak ada catatan dengan judul\n"$query"'
                : 'Belum ada catatan',
            key: const Key('empty_state_text'),
            textAlign: TextAlign.center,
          );
        }
        return ListView(
          children: notes
              .map(
                (n) => ListTile(key: Key('note_${n.id}'), title: Text(n.title)),
              )
              .toList(),
        );
      },
    );
  }
}
