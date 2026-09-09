import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo.dart';

/// State notifier managing the list of ToDo items with immutable updates.
class TodoListNotifier extends Notifier<List<Todo>> {
  @override
  List<Todo> build() => const [];

  /// Adds a new task to the list without mutating existing state.
  void add(String title) {
    if (title.trim().isEmpty) return;
    state = [...state, Todo(title: title.trim())];
  }

  /// Toggles the completion status of a task at the given index.
  void toggle(int index) {
    if (index < 0 || index >= state.length) return;
    final todos = [...state];
    todos[index] = todos[index].copyWith(done: !todos[index].done);
    state = todos;
  }

  /// Removes a task from the list at the given index.
  void remove(int index) {
    if (index < 0 || index >= state.length) return;
    state = [...state]..removeAt(index);
  }

  /// Replaces the whole list (useful for initial demo / testing).
  void setInitialList(List<Todo> todos) {
    state = List.unmodifiable(todos);
  }
}

/// Global provider for managing the ToDo list state.
final todoListProvider =
    NotifierProvider<TodoListNotifier, List<Todo>>(TodoListNotifier.new);
