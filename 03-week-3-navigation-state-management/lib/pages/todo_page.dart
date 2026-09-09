import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/todo_filter_provider.dart';
import '../providers/todo_provider.dart';
import '../widgets/todo_tile.dart';

/// Main ToDo list page built using Riverpod ConsumerWidget.
/// Observes filtered tasks and dispatches state updates via Notifier methods.
class TodoPage extends ConsumerWidget {
  const TodoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. ref.watch listens to reactive changes in filtered list and current filter
    final filteredTodos = ref.watch(filteredTodoListProvider);
    final currentFilter = ref.watch(todoFilterProvider);
    final allTodos = ref.watch(todoListProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ToDo Riverpod'),
        actions: [
          IconButton(
            icon: const Icon(Icons.explore_outlined),
            tooltip: 'Praktikum 1 Demo',
            onPressed: () => context.push('/demo-router'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Selector (Refactoring Challenge #2)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SegmentedButton<TodoFilter>(
              segments: const [
                ButtonSegment(
                  value: TodoFilter.all,
                  label: Text('Semua'),
                  icon: Icon(Icons.list_alt),
                ),
                ButtonSegment(
                  value: TodoFilter.active,
                  label: Text('Aktif'),
                  icon: Icon(Icons.check_box_outline_blank),
                ),
                ButtonSegment(
                  value: TodoFilter.completed,
                  label: Text('Selesai'),
                  icon: Icon(Icons.check_box),
                ),
              ],
              selected: {currentFilter},
              onSelectionChanged: (newSelection) {
                ref.read(todoFilterProvider.notifier).setFilter(newSelection.first);
              },
            ),
          ),

          // Task List or Empty State
          Expanded(
            child: filteredTodos.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.task_alt,
                          size: 64,
                          color: theme.colorScheme.outline.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          allTodos.isEmpty
                              ? 'Belum ada tugas'
                              : 'Tidak ada tugas pada filter ini',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          allTodos.isEmpty
                              ? 'Tekan tombol + untuk menambahkan tugas baru'
                              : 'Coba ubah filter di atas',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 4.0, bottom: 80.0),
                    itemCount: filteredTodos.length,
                    itemBuilder: (context, index) {
                      final todo = filteredTodos[index];
                      // Find actual index in raw list for accurate mutation
                      final rawIndex = allTodos.indexOf(todo);

                      return TodoTile(
                        todo: todo,
                        onToggle: (_) =>
                            ref.read(todoListProvider.notifier).toggle(rawIndex),
                        onDelete: () =>
                            ref.read(todoListProvider.notifier).remove(rawIndex),
                        onTap: () => context.push('/detail/${rawIndex + 1}'),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Tugas Baru'),
      ),
    );
  }

  /// Dialog to enter and add a new ToDo item to the provider state.
  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tugas baru'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Contoh: Kerjakan PR minggu 3',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              ref.read(todoListProvider.notifier).add(value.trim());
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref.read(todoListProvider.notifier).add(controller.text.trim());
              }
              Navigator.pop(context);
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }
}
