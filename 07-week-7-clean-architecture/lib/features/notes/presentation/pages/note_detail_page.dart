import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/format.dart';
import '../../domain/entities/note.dart';
import '../providers/notes_providers.dart';

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
        // Catatan Baru
        await ref.read(notesProvider.notifier).addNote(
              title: title,
              body: body,
            );
      } else {
        // Update Catatan yang sudah ada
        final noteToUpdate = (existingNote ??
                Note(
                  id: widget.noteId,
                  title: title,
                  body: body,
                  updatedAt: DateTime.now(),
                  dirty: true,
                ))
            .copyWith(
          title: title,
          body: body,
        );
        await ref.read(notesProvider.notifier).updateNote(noteToUpdate);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Catatan berhasil disimpan!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e'),
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
    final isNew = widget.noteId == null;

    if (isNew) {
      return _buildScaffold(
        context: context,
        title: 'Buat Catatan Baru',
        isNew: true,
      );
    }

    final noteDetailAsync = ref.watch(noteDetailProvider(widget.noteId!));

    return noteDetailAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Memuat Catatan...')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Gagal memuat catatan: $err'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () =>
                    ref.invalidate(noteDetailProvider(widget.noteId!)),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
      data: (note) {
        if (note == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Tidak Ditemukan')),
            body: const Center(child: Text('Catatan tidak ditemukan.')),
          );
        }
        _populateControllers(note);
        return _buildScaffold(
          context: context,
          title: 'Edit Catatan #${note.id}',
          isNew: false,
          note: note,
        );
      },
    );
  }

  Widget _buildScaffold({
    required BuildContext context,
    required String title,
    required bool isNew,
    Note? note,
  }) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.check),
            tooltip: 'Simpan',
            onPressed: _isSaving ? null : () => _saveNote(existingNote: note),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (note != null) ...[
                Card(
                  elevation: 0,
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Status: ${formatDirtyStatus(note.dirty)}',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          formatDateTime(note.updatedAt),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul Catatan',
                  hintText: 'Masukkan judul catatan...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Judul tidak boleh kosong';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bodyController,
                decoration: const InputDecoration(
                  labelText: 'Isi Catatan',
                  hintText: 'Tuliskan isi catatan di sini...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 8,
                textAlignVertical: TextAlignVertical.top,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed:
                    _isSaving ? null : () => _saveNote(existingNote: note),
                icon: const Icon(Icons.save),
                label: Text(
                  _isSaving
                      ? 'Menyimpan...'
                      : (isNew ? 'Tambah Catatan' : 'Simpan Perubahan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
