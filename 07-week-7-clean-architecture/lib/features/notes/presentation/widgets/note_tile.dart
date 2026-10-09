import 'package:flutter/material.dart';
import '../../../../core/format.dart';
import '../../domain/entities/note.dart';

class NoteTile extends StatelessWidget {
  const NoteTile({
    super.key,
    required this.note,
    required this.onTap,
    required this.onDelete,
  });

  final Note note;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: note.dirty
              ? (isDark ? Colors.amber.shade900 : Colors.amber.shade300)
              : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
          width: note.dirty ? 1.5 : 1.0,
        ),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: theme.colorScheme.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      note.title.isEmpty ? '(Tanpa Judul)' : note.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: note.dirty
                          ? (isDark ? Colors.amber.shade900 : Colors.amber.shade100)
                          : (isDark ? Colors.teal.shade900 : Colors.teal.shade50),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      formatDirtyStatus(note.dirty),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: note.dirty
                            ? (isDark ? Colors.amber.shade200 : Colors.amber.shade900)
                            : (isDark ? Colors.teal.shade200 : Colors.teal.shade900),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    color: Colors.red.shade400,
                    tooltip: 'Hapus Catatan',
                    onPressed: onDelete,
                  ),
                ],
              ),
              if (note.body.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  note.body,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: theme.hintColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    formatDateTime(note.updatedAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
