import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'local/note.dart';
import 'models/post.dart';
import 'prefs.dart';
import 'repositories/note_repository.dart';
import 'sync.dart';

/// Provider repository preferensi (SharedPreferences)
final prefsRepositoryProvider = Provider<PrefsRepository>((ref) => PrefsRepository());

/// Notifier untuk mode gelap (Praktikum 1)
final darkModeProvider =
    AsyncNotifierProvider<DarkModeNotifier, bool>(DarkModeNotifier.new);

class DarkModeNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() =>
      ref.watch(prefsRepositoryProvider).getDarkMode();

  Future<void> toggle() async {
    final next = !(state.value ?? false);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(prefsRepositoryProvider).setDarkMode(next);
      return next;
    });
  }

  Future<void> setDarkMode(bool value) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(prefsRepositoryProvider).setDarkMode(value);
      return value;
    });
  }
}

/// Provider waktu terakhir aplikasi dibuka
final lastOpenedProvider = FutureProvider<String?>((ref) async {
  return ref.watch(prefsRepositoryProvider).getLastOpened();
});

/// Provider repository catatan SQLite (Praktikum 2)
final noteRepositoryProvider =
    Provider<NoteRepository>((ref) => NoteRepository());

/// Provider daftar catatan dengan AsyncNotifier
final notesProvider =
    AsyncNotifierProvider<NotesNotifier, List<Note>>(
  NotesNotifier.new,
  retry: (retryCount, error) => null,
);

class NotesNotifier extends AsyncNotifier<List<Note>> {
  @override
  Future<List<Note>> build() async {
    final repo = ref.watch(noteRepositoryProvider);
    return repo.fetchNotes();
  }

  Future<void> addNote({required String title, String body = ''}) async {
    final repo = ref.read(noteRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.addNote(title: title, body: body);
      return repo.fetchNotes();
    });
  }

  Future<void> updateNote(Note note) async {
    final repo = ref.read(noteRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.updateNote(note);
      return repo.fetchNotes();
    });
  }

  Future<void> deleteNote(int id) async {
    final repo = ref.read(noteRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.deleteNote(id);
      return repo.fetchNotes();
    });
  }

  Future<int> sync() async {
    final repo = ref.read(noteRepositoryProvider);
    final count = await syncNotes(repo);
    ref.invalidateSelf();
    return count;
  }
}

/// Provider family untuk membaca detail catatan langsung dari SQLite lokal
final noteDetailProvider =
    FutureProvider.family<Note?, int>((ref, id) async {
  final repo = ref.watch(noteRepositoryProvider);
  return repo.getNoteById(id);
});

/// Provider jumlah catatan yang belum disinkronkan (dirty flag)
final dirtyCountProvider = FutureProvider<int>((ref) async {
  ref.watch(notesProvider);
  final repo = ref.watch(noteRepositoryProvider);
  return repo.countDirty();
});

/// Provider simulasi Force Offline (Praktikum 3)
final forceOfflineProvider =
    NotifierProvider<ForceOfflineNotifier, bool>(ForceOfflineNotifier.new);

class ForceOfflineNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
  void setOffline(bool value) => state = value;
}

/// Provider status sedang melakukan sinkronisasi
final isSyncingProvider =
    NotifierProvider<IsSyncingNotifier, bool>(IsSyncingNotifier.new);

class IsSyncingNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setSyncing(bool value) => state = value;
}

/// Provider SyncService
final syncServiceProvider = Provider<SyncService>((ref) => SyncService());

/// Provider Cache-first read untuk REST API posts (Praktikum 3)
final cachedPostsProvider =
    AsyncNotifierProvider<CachedPostsNotifier, List<Post>>(
  CachedPostsNotifier.new,
  retry: (retryCount, error) => null,
);

class CachedPostsNotifier extends AsyncNotifier<List<Post>> {
  @override
  Future<List<Post>> build() async {
    final syncService = ref.watch(syncServiceProvider);
    final isForceOffline = ref.watch(forceOfflineProvider);

    // 1. Baca cache lokal seketika agar UI tidak blank
    final cached = await syncService.readCachedPosts();

    // 2. Di background: jika tidak force offline, fetch remote dan simpan ke SQLite
    if (!isForceOffline) {
      _refreshInBackground(syncService);
    }

    return cached;
  }

  Future<void> _refreshInBackground(SyncService syncService) async {
    try {
      final remote = await syncService.fetchRemotePosts();
      await syncService.saveCachedPosts(remote);
      // Perbarui state dengan data terbaru jika provider masih terpasang
      state = AsyncData(remote);
    } catch (_) {
      // Jika remote gagal (misal tidak ada sinyal), pertahankan cache lokal
    }
  }

  Future<void> refresh() async {
    final syncService = ref.read(syncServiceProvider);
    final isForceOffline = ref.read(forceOfflineProvider);

    if (isForceOffline) {
      // Saat offline, hanya baca dari cache
      final cached = await syncService.readCachedPosts();
      state = AsyncData(cached);
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final remote = await syncService.fetchRemotePosts();
      await syncService.saveCachedPosts(remote);
      return remote;
    });
  }
}
