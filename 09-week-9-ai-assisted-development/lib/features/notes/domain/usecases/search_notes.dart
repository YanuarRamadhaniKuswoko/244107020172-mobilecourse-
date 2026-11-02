import '../entities/note.dart';

/// Use case domain murni: filter daftar catatan berdasarkan query judul.
///
/// Sengaja tidak menyentuh repository agar dapat diuji tanpa database.
/// [AI-generated, verified, refactored] – lihat docs/ai-log.md untuk detail.
///
/// Keputusan refactor:
/// - AI awalnya menempatkan logika filter di widget (halusinasi arsitektur).
/// - Dipindahkan ke domain use case agar presentation layer bebas logika bisnis.
List<Note> filterNotes(List<Note> notes, String query) {
  final trimmed = query.trim();
  if (trimmed.isEmpty) return List.unmodifiable(notes);
  final lowerQuery = trimmed.toLowerCase();
  return notes
      .where((n) => n.title.toLowerCase().contains(lowerQuery))
      .toList();
}

/// Use case wrapper yang mengikuti pola proyek.
class SearchNotes {
  const SearchNotes();

  /// Kembalikan catatan yang judulnya mengandung [query] (case-insensitive).
  /// Query kosong mengembalikan semua catatan.
  List<Note> call(List<Note> notes, String query) => filterNotes(notes, query);
}
