import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/stats_provider.dart';

/// StatsPage is a ConsumerWidget displaying analytical data managed asynchronously by Riverpod.
/// It observes `statsProvider` and handles all three AsyncValue states: Loading, Error, and Success.
class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // 1. ref.watch listens to changes in statsProvider and rebuilds the widget when state updates.
    final statsAsync = ref.watch(statsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistik & Analitik'),
        actions: [
          // Action button to trigger manual refresh (invalidate resets provider and re-executes build)
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Segarkan Data',
            onPressed: () => ref.invalidate(statsProvider),
          ),
        ],
      ),
      // 2. AsyncValue.when maps all 3 states cleanly without boilerplate booleans
      body: statsAsync.when(
        // === STATE 1: LOADING ===
        // Displayed while the asynchronous fetch operation is in progress (2s delay simulation)
        loading: () => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Memuat data statistik...',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),

        // === STATE 2: ERROR ===
        // Displayed when an exception occurs (e.g. simulated 30% network failure)
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              color: theme.colorScheme.errorContainer,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.cloud_off,
                      size: 48,
                      color: theme.colorScheme.onErrorContainer,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Gagal Memuat Statistik',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      err.toString().replaceAll('Exception: ', ''),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Ref.read in callbacks triggers refresh without creating reactive subscriptions
                    FilledButton.icon(
                      onPressed: () => ref.invalidate(statsProvider),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // === STATE 3: SUCCESS / DATA ===
        // Displayed when data has successfully loaded into the TaskStats model
        data: (stats) => ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Overall summary card
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: theme.colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text(
                      'Tingkat Penyelesaian',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${stats.completionRate.toStringAsFixed(1)}%',
                      style: theme.textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: stats.totalTasks == 0
                            ? 0.0
                            : stats.completedTasks / stats.totalTasks,
                        minHeight: 8,
                        backgroundColor: theme.colorScheme.surface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Rincian Tugas',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Item 1: Total Tasks
            ListTile(
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.secondaryContainer,
                child: Icon(Icons.format_list_bulleted,
                    color: theme.colorScheme.onSecondaryContainer),
              ),
              title: const Text('Total Tugas'),
              subtitle: const Text('Semua tugas yang telah didaftarkan'),
              trailing: Text(
                '${stats.totalTasks}',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),

            // Item 2: Completed Tasks
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.green,
                child: Icon(Icons.check_circle_outline, color: Colors.white),
              ),
              title: const Text('Tugas Selesai'),
              subtitle: const Text('Tugas yang telah ditandai selesai'),
              trailing: Text(
                '${stats.completedTasks}',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
            const Divider(),

            // Item 3: Pending Tasks
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.orange,
                child: Icon(Icons.pending_actions, color: Colors.white),
              ),
              title: const Text('Tugas Tertunda'),
              subtitle: const Text('Tugas yang masih perlu diselesaikan'),
              trailing: Text(
                '${stats.pendingTasks}',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ),

            const SizedBox(height: 24),
            // Simulator toggle / force refresh for demonstration during evaluation
            OutlinedButton.icon(
              onPressed: () {
                ref.read(statsProvider.notifier).refresh(forceError: true);
              },
              icon: const Icon(Icons.bug_report),
              label: const Text('Uji Simulasi Error (Asesmen)'),
            ),
          ],
        ),
      ),
    );
  }
}
