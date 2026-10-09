import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/note.dart';
import '../providers/notes_providers.dart';
import '../widgets/note_tile.dart';

class NotesPage extends ConsumerStatefulWidget {
  const NotesPage({super.key});

  @override
  ConsumerState<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends ConsumerState<NotesPage> {
  bool _isSyncing = false;

  Future<void> _handleSync() async {
    final dirtyCount = (await ref.read(dirtyCountProvider.future));
    if (dirtyCount == 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Semua catatan sudah tersinkronkan (dirty = 0).'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    setState(() => _isSyncing = true);
    try {
      final synced = await ref.read(notesProvider.notifier).sync();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Berhasil menyinkronkan $synced catatan ke server!'),
            backgroundColor: Colors.teal.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal sinkronisasi: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  Future<void> _deleteNoteWithConfirmation(Note note) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Catatan?'),
        content: Text('Apakah Anda yakin ingin menghapus "${note.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true && note.id != null) {
      try {
        await ref.read(notesProvider.notifier).deleteNote(note.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Catatan berhasil dihapus'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menghapus catatan: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(notesProvider);
    final dirtyCountAsync = ref.watch(dirtyCountProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Offline (Clean Arch)'),
        actions: [
          IconButton(
            icon: _isSyncing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Badge(
                    label: Text('${dirtyCountAsync.value ?? 0}'),
                    isLabelVisible: (dirtyCountAsync.value ?? 0) > 0,
                    child: const Icon(Icons.sync),
                  ),
            tooltip: 'Sinkronisasi Catatan Offline',
            onPressed: _isSyncing ? null : _handleSync,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Muat Ulang',
            onPressed: () {
              ref.invalidate(notesProvider);
              ref.invalidate(dirtyCountProvider);
            },
          ),
        ],
      ),
      body: notesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Terjadi kesalahan:\n$err',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                FilledButton.tonal(
                  onPressed: () {
                    ref.invalidate(notesProvider);
                    ref.invalidate(dirtyCountProvider);
                  },
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
        data: (notes) {
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Card(
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.layers_outlined,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Clean Architecture Feature-First',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Presentation ➔ Domain ➔ Data (Steril & DI Riverpod)',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (notes.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.note_alt_outlined,
                          size: 64,
                          color: theme.hintColor.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada catatan',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tekan tombol + untuk membuat catatan baru.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final note = notes[index];
                      return NoteTile(
                        note: note,
                        onTap: () {
                          if (note.id != null) {
                            context.push('/note/${note.id}');
                          }
                        },
                        onDelete: () => _deleteNoteWithConfirmation(note),
                      );
                    },
                    childCount: notes.length,
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/note/new'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
