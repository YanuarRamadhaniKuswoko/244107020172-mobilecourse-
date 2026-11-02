import 'package:flutter/material.dart';

import '../../../../core/format.dart';
import '../../domain/entities/note.dart';

class NoteTile extends StatelessWidget {
  const NoteTile({
    super.key,
    required this.note,
    required this.onTap,
    required this.onDelete,
    this.highlightQuery = '',
  });

  final Note note;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  /// Query teks aktif — dipakai untuk highlight teks yang cocok di judul.
  final String highlightQuery;

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
                    child: _buildHighlightedTitle(
                      context,
                      note.title.isEmpty ? '(Tanpa Judul)' : note.title,
                      highlightQuery,
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
                          ? (isDark
                                ? Colors.amber.shade900
                                : Colors.amber.shade100)
                          : (isDark
                                ? Colors.teal.shade900
                                : Colors.teal.shade50),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      formatDirtyStatus(note.dirty),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: note.dirty
                            ? (isDark
                                  ? Colors.amber.shade200
                                  : Colors.amber.shade900)
                            : (isDark
                                  ? Colors.teal.shade200
                                  : Colors.teal.shade900),
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
                    color: theme.textTheme.bodyMedium?.color?.withValues(
                      alpha: 0.8,
                    ),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: theme.hintColor),
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

  /// Kembalikan RichText dengan bagian yang cocok di-highlight kuning.
  Widget _buildHighlightedTitle(
    BuildContext context,
    String title,
    String query,
  ) {
    final theme = Theme.of(context);
    final baseStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.bold,
    );

    if (query.trim().isEmpty) {
      return Text(
        title,
        style: baseStyle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    final lowerTitle = title.toLowerCase();
    final lowerQuery = query.trim().toLowerCase();
    final spans = <TextSpan>[];
    int start = 0;

    while (true) {
      final idx = lowerTitle.indexOf(lowerQuery, start);
      if (idx == -1) {
        spans.add(TextSpan(text: title.substring(start)));
        break;
      }
      if (idx > start) {
        spans.add(TextSpan(text: title.substring(start, idx)));
      }
      spans.add(
        TextSpan(
          text: title.substring(idx, idx + lowerQuery.length),
          style: const TextStyle(
            backgroundColor: Color(0xFFFFE566),
            color: Colors.black87,
          ),
        ),
      );
      start = idx + lowerQuery.length;
    }

    return Text.rich(
      TextSpan(children: spans, style: baseStyle),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
