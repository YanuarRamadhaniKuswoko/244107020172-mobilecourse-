import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local/note.dart';
import '../data/providers.dart';

class NoteDetailPage extends ConsumerStatefulWidget {
  const NoteDetailPage({
    super.key,
    this.noteId,
  });

  final int? noteId;

  @override
  ConsumerState<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends ConsumerState<NoteDetailPage> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  bool _isInitialized = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _populateControllers(Note note) {
    if (!_isInitialized) {
      _titleController.text = note.title;
      _bodyController.text = note.body;
      _isInitialized = true;
    }
  }

  Future<void> _saveNote({Note? existingNote}) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final title = _titleController.text.trim();
      final body = _bodyController.text.trim();

      if (existingNote == null && widget.noteId == null) {
        // Catatan Baru (dirty = true)
        await ref.read(notesProvider.notifier).addNote(
              title: title,
              body: body,
            );
      } else {
        // Update Catatan (dirty = true)
        final noteToUpdate = (existingNote ??
            Note(
              id: widget.noteId,
              title: title,
              body: body,
              updatedAt: DateTime.now(),
              dirty: true,
            )).copyWith(
          title: title,
          body: body,
        );

        await ref.read(notesProvider.notifier).updateNote(noteToUpdate);
        if (widget.noteId != null) {
          ref.invalidate(noteDetailProvider(widget.noteId!));
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.noteId == null
                  ? 'Catatan baru tersimpan secara lokal (dirty = 1)'
                  : 'Catatan diperbarui secara lokal (dirty = 1)',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan catatan: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.noteId != null;

    if (isEditing) {
      // Membaca detail catatan langsung dari repository lokal SQLite
      final noteAsync = ref.watch(noteDetailProvider(widget.noteId!));

      return noteAsync.when(
        data: (note) {
          if (note == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Catatan Tidak Ditemukan')),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.search_off_rounded,
                        size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      'Catatan dengan ID ${widget.noteId} tidak ditemukan di database SQLite.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Kembali'),
                    ),
                  ],
                ),
              ),
            );
          }

          _populateControllers(note);

          return _buildFormScaffold(
            context: context,
            theme: theme,
            isEditing: true,
            note: note,
          );
        },
        loading: () => Scaffold(
          appBar: AppBar(title: const Text('Memuat Catatan...')),
          body: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        error: (err, _) => Scaffold(
          appBar: AppBar(title: const Text('Error')),
          body: Center(
            child: Text('Gagal memuat catatan dari repository: $err'),
          ),
        ),
      );
    }

    return _buildFormScaffold(
      context: context,
      theme: theme,
      isEditing: false,
      note: null,
    );
  }

  Widget _buildFormScaffold({
    required BuildContext context,
    required ThemeData theme,
    required bool isEditing,
    Note? note,
  }) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Catatan (SQLite)' : 'Catatan Baru'),
        actions: [
          IconButton(
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_rounded),
            tooltip: 'Simpan Catatan',
            onPressed: _isSaving ? null : () => _saveNote(existingNote: note),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (isEditing && note != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: note.dirty
                      ? Colors.amber.withValues(alpha: 0.15)
                      : Colors.green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: note.dirty
                        ? Colors.amber.shade700
                        : Colors.green.shade700,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      note.dirty
                          ? Icons.sync_problem_rounded
                          : Icons.cloud_done_rounded,
                      color: note.dirty
                          ? Colors.amber.shade800
                          : Colors.green.shade800,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            note.dirty
                                ? 'Status: Belum Tersinkron (dirty = 1)'
                                : 'Status: Tersinkron (dirty = 0)',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            'ID: ${note.id} | Terakhir diubah: ${note.updatedAt}',
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Judul Catatan',
                hintText: 'Masukkan judul catatan...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                prefixIcon: Icon(Icons.title_rounded),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Judul catatan tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _bodyController,
              decoration: const InputDecoration(
                labelText: 'Isi Catatan',
                hintText: 'Tulis isi catatan di sini...',
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              maxLines: 10,
              keyboardType: TextInputType.multiline,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed:
                  _isSaving ? null : () => _saveNote(existingNote: note),
              icon: const Icon(Icons.save_rounded),
              label: Text(
                _isSaving
                    ? 'Menyimpan...'
                    : (isEditing ? 'Perbarui Catatan' : 'Simpan Catatan'),
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
