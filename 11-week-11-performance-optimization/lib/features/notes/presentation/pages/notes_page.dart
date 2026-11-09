import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/note.dart';
import '../providers/notes_providers.dart';
import '../widgets/note_tile.dart';

/// Section 4.B Jobsheet: Ekstraksi Widget ke Class Terpisah (bisa const)
class NotesHeaderBanner extends StatelessWidget {
  const NotesHeaderBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Card(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(
                Icons.speed_outlined,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Clean Architecture + Optimasi Performa',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Paginasi, RepaintBoundary, Riverpod select & Cache',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Section 4.B Jobsheet: Ekstraksi widget empty state ke class terpisah const
class EmptyNotesView extends StatelessWidget {
  const EmptyNotesView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
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
    );
  }
}

/// Section 4.D Jobsheet: Consumer widget dengan Riverpod select untuk isolasi rebuild
class SyncActionWidget extends ConsumerWidget {
  const SyncActionWidget({
    super.key,
    required this.isSyncing,
    required this.onSync,
  });

  final bool isSyncing;
  final VoidCallback onSync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Hanya rebuild tombol badge jika dirtyCount berubah, bukan seluruh NotesPage
    final dirtyCount = ref.watch(
      dirtyCountProvider.select((asyncVal) => asyncVal.value ?? 0),
    );

    return IconButton(
      icon: isSyncing
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Badge(
              label: Text('$dirtyCount'),
              isLabelVisible: dirtyCount > 0,
              child: const Icon(Icons.sync),
            ),
      tooltip: 'Sinkronisasi Catatan Offline',
      onPressed: isSyncing ? null : onSync,
    );
  }
}

/// Halaman utama dengan optimasi performa (Jobsheet Minggu 11)
class NotesPage extends ConsumerStatefulWidget {
  const NotesPage({super.key});

  @override
  ConsumerState<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends ConsumerState<NotesPage> {
  // Section 5.2 Jobsheet: Pagination (Infinite Scroll) dengan ScrollController
  final _scrollController = ScrollController();
  final List<Note> _items = [];
  int _page = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    // Tambah scroll listener untuk mendeteksi threshold pagination
    _scrollController.addListener(_onScroll);
    _loadPage(reset: true);
  }

  // Section 5.2 Jobsheet: Deteksi scroll hingga 200px sebelum batas akhir
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadPage();
    }
  }

  // Section 5.2 Jobsheet: Muat halaman berikutnya secara lazy
  Future<void> _loadPage({bool reset = false}) async {
    if (_isLoading) return;
    if (reset) {
      _page = 1;
      _hasMore = true;
      _items.clear();
    }
    if (!_hasMore) return;

    _isLoading = true;
    if (mounted) setState(() {});

    try {
      final repo = ref.read(noteRepositoryProvider);
      final result = await repo.fetchNotesPaginated(page: _page, pageSize: 10);
      if (result.failure != null) {
        throw Exception(result.failure!.message);
      }
      final newItems = result.notes;
      if (newItems.isEmpty || !result.hasMore) {
        _hasMore = false;
      }
      _items.addAll(newItems);
      if (result.hasMore) {
        _page++;
      }
    } catch (_) {
      // Fallback ke fetchNotes standar jika repository belum mendukung paginasi
      try {
        final allResult = await ref.read(noteRepositoryProvider).fetchNotes();
        _items.clear();
        _items.addAll(allResult.notes);
        _hasMore = false;
      } catch (_) {}
    } finally {
      _isLoading = false;
      if (mounted) setState(() {});
    }
  }

  // Section 7 Langkah 5: Memory Profiling & Pencegahan Leak dengan dispose()
  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // Section 4.E Jobsheet: Hindari Anonymous Function di Build (gunakan method reference)
  void _handleRefresh() {
    ref.invalidate(dirtyCountProvider);
    _loadPage(reset: true);
  }

  void _navigateToCreateNote() {
    context.push('/note/new').then((_) => _handleRefresh());
  }

  void _handleNoteTap(Note note) {
    if (note.id != null) {
      context.push('/note/${note.id}').then((_) => _handleRefresh());
    }
  }

  Future<void> _handleSync() async {
    final dirtyCount = await ref.read(dirtyCountProvider.future);
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
      _handleRefresh();
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
        _handleRefresh();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Offline (Clean Arch)'),
        actions: [
          // Section 4.D: Consumer widget dengan Riverpod select
          SyncActionWidget(
            isSyncing: _isSyncing,
            onSync: _handleSync,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Muat Ulang',
            // Section 4.E: Method reference, bukan anonymous closure
            onPressed: _handleRefresh,
          ),
        ],
      ),
      body: Column(
        children: [
          // Section 4.A & 4.B: Ekstrak Widget const
          const NotesHeaderBanner(),
          Expanded(
            child: _isLoading && _items.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _items.isEmpty
                    ? const EmptyNotesView()
                    // Section 5.1 & 5.2: Lazy Loading ListView.builder dengan pagination
                    : RefreshIndicator(
                        onRefresh: () async => _handleRefresh(),
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: _items.length + (_hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _items.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            final note = _items[index];
                            // Section 4.C: RepaintBoundary untuk isolasi repaint render tiap tile
                            return RepaintBoundary(
                              child: NoteTile(
                                note: note,
                                onTap: () => _handleNoteTap(note),
                                onDelete: () => _deleteNoteWithConfirmation(note),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        // Section 4.E: Method tear-off reference
        onPressed: _navigateToCreateNote,
        child: const Icon(Icons.add),
      ),
    );
  }
}
