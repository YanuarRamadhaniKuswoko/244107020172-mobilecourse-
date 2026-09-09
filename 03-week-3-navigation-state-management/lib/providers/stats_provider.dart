import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/stats.dart';
import 'todo_provider.dart';

/// AsyncNotifier managing asynchronous statistical data fetching.
/// Simulates a remote API call with network latency and potential failure (30%).
class StatsNotifier extends AsyncNotifier<TaskStats> {
  /// Toggle to enable 30% random failure simulation.
  bool enableRandomFailures = true;

  @override
  Future<TaskStats> build() async {
    return _fetchStats();
  }

  /// Triggers a re-fetch of stats wrapped in AsyncValue.guard.
  Future<void> refresh({bool forceError = false}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchStats(forceError: forceError));
  }

  /// Internal data fetching logic with simulated delay.
  Future<TaskStats> _fetchStats({bool forceError = false}) async {
    // Simulate 2-second network latency
    await Future.delayed(const Duration(seconds: 2));

    // Simulate potential 30% failure rate or explicit test trigger
    if (forceError || (enableRandomFailures && Random().nextDouble() < 0.30)) {
      throw Exception('Gagal terhubung ke server statistik (503 Service Unavailable).');
    }

    // Compute live metrics from current ToDo list
    final todos = ref.read(todoListProvider);
    final total = todos.length;
    final completed = todos.where((t) => t.done).length;
    final pending = total - completed;

    return TaskStats(
      totalTasks: total,
      completedTasks: completed,
      pendingTasks: pending,
      categories: const ['Kuliah', 'Praktikum', 'Tugas Akhir'],
    );
  }
}

/// Global provider exposing task statistics as an AsyncValue.
final statsProvider =
    AsyncNotifierProvider<StatsNotifier, TaskStats>(StatsNotifier.new);
