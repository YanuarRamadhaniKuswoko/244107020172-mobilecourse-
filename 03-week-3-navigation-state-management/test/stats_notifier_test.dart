import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week3_navigation_state/models/stats.dart';
import 'package:week3_navigation_state/providers/stats_provider.dart';
import 'package:week3_navigation_state/providers/todo_provider.dart';

void main() {
  group('StatsNotifier Unit Tests', () {
    test('StatsNotifier computes correct statistics from TodoList state', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Disable random failures for deterministic unit test
      final statsNotifier = container.read(statsProvider.notifier);
      statsNotifier.enableRandomFailures = false;

      final todoNotifier = container.read(todoListProvider.notifier);
      todoNotifier.add('Tugas A');
      todoNotifier.add('Tugas B');
      todoNotifier.toggle(0); // 1 completed, 1 pending

      // Read future from statsProvider
      final result = await container.read(statsProvider.future);

      expect(result, isA<TaskStats>());
      expect(result.totalTasks, 2);
      expect(result.completedTasks, 1);
      expect(result.pendingTasks, 1);
      expect(result.completionRate, 50.0);
    });

    test('StatsNotifier handles error when forced to fail', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final statsNotifier = container.read(statsProvider.notifier);
      statsNotifier.enableRandomFailures = false;

      // Trigger refresh with forced error
      await statsNotifier.refresh(forceError: true);

      final asyncState = container.read(statsProvider);
      expect(asyncState.hasError, isTrue);
      expect(asyncState.error.toString(), contains('503'));
    });
  });
}
