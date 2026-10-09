/// Pure domain entity for Note.
/// Note that domain entities must not contain serialization methods
/// (e.g., toMap, fromMap, toJson) or Flutter framework dependencies.
class Note {
  const Note({
    this.id,
    required this.title,
    this.body = '',
    required this.updatedAt,
    this.dirty = false,
  });

  final int? id;
  final String title;
  final String body;
  final DateTime updatedAt;
  final bool dirty;

  Note copyWith({
    int? id,
    String? title,
    String? body,
    DateTime? updatedAt,
    bool? dirty,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      updatedAt: updatedAt ?? this.updatedAt,
      dirty: dirty ?? this.dirty,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Note &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          body == other.body &&
          updatedAt == other.updatedAt &&
          dirty == other.dirty;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      body.hashCode ^
      updatedAt.hashCode ^
      dirty.hashCode;

  @override
  String toString() =>
      'Note(id: $id, title: $title, dirty: $dirty, updatedAt: $updatedAt)';
}

