import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo.dart';
import 'todo_provider.dart';

/// Enum defining available task filter categories.
enum TodoFilter {
  all,
  active,
  completed,
}

/// Notifier managing the active filter state.
class TodoFilterNotifier extends Notifier<TodoFilter> {
  @override
  TodoFilter build() => TodoFilter.all;

  /// Changes the active filter.
  void setFilter(TodoFilter filter) {
    state = filter;
  }
}

/// Provider exposing the current filter selection.
final todoFilterProvider =
    NotifierProvider<TodoFilterNotifier, TodoFilter>(TodoFilterNotifier.new);

/// Derived Provider extracting and filtering the ToDo list based on the active filter.
final filteredTodoListProvider = Provider<List<Todo>>((ref) {
  final todos = ref.watch(todoListProvider);
  final filter = ref.watch(todoFilterProvider);

  switch (filter) {
    case TodoFilter.completed:
      return todos.where((todo) => todo.done).toList();
    case TodoFilter.active:
      return todos.where((todo) => !todo.done).toList();
    case TodoFilter.all:
      return todos;
  }
});
