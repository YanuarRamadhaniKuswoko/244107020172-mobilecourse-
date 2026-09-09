class Todo {
  const Todo({
    required this.title,
    this.done = false,
  });

  final String title;
  final bool done;

  Todo copyWith({
    String? title,
    bool? done,
  }) {
    return Todo(
      title: title ?? this.title,
      done: done ?? this.done,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Todo &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          done == other.done;

  @override
  int get hashCode => title.hashCode ^ done.hashCode;
}
