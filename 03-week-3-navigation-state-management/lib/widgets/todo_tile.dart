import 'package:flutter/material.dart';
import '../models/todo.dart';

/// Reusable modular tile widget for displaying and interacting with a single ToDo item.
/// Extracted to keep the parent widget clean and enable isolated widget testing.
class TodoTile extends StatelessWidget {
  const TodoTile({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onDelete,
    this.onTap,
  });

  final Todo todo;
  final ValueChanged<bool?> onToggle;
  final VoidCallback onDelete;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
        leading: Checkbox(
          value: todo.done,
          onChanged: onToggle,
          activeColor: theme.colorScheme.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            decoration: todo.done ? TextDecoration.lineThrough : null,
            color: todo.done
                ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6)
                : theme.colorScheme.onSurface,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          color: theme.colorScheme.error,
          tooltip: 'Hapus Tugas',
          onPressed: onDelete,
        ),
      ),
    );
  }
}
