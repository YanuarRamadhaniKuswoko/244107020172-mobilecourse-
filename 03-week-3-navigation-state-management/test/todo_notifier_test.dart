import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week3_navigation_state/providers/todo_filter_provider.dart';
import 'package:week3_navigation_state/providers/todo_provider.dart';

void main() {
  group('TodoListNotifier Unit Tests', () {
    test('Initial state should be an empty list', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final todos = container.read(todoListProvider);
      expect(todos, isEmpty);
    });

    test('add() should append a new Todo immutably', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(todoListProvider.notifier);
      notifier.add('Belajar GoRouter');

      final todos = container.read(todoListProvider);
      expect(todos.length, 1);
      expect(todos.first.title, 'Belajar GoRouter');
      expect(todos.first.done, false);
    });

    test('toggle() should flip the done status of the target item', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(todoListProvider.notifier);
      notifier.add('Belajar Riverpod');
      notifier.toggle(0);

      var todos = container.read(todoListProvider);
      expect(todos.first.done, true);

      notifier.toggle(0);
      todos = container.read(todoListProvider);
      expect(todos.first.done, false);
    });

    test('remove() should delete the item at specified index', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(todoListProvider.notifier);
      notifier.add('Tugas 1');
      notifier.add('Tugas 2');

      expect(container.read(todoListProvider).length, 2);

      notifier.remove(0);

      final todos = container.read(todoListProvider);
      expect(todos.length, 1);
      expect(todos.first.title, 'Tugas 2');
    });
  });

  group('filteredTodoListProvider Tests', () {
    test('Filters active and completed tasks correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final todoNotifier = container.read(todoListProvider.notifier);
      final filterNotifier = container.read(todoFilterProvider.notifier);

      todoNotifier.add('Tugas Belum Selesai 1');
      todoNotifier.add('Tugas Selesai 1');
      todoNotifier.toggle(1); // mark as done
      todoNotifier.add('Tugas Belum Selesai 2');

      // 1. Filter All
      filterNotifier.setFilter(TodoFilter.all);
      expect(container.read(filteredTodoListProvider).length, 3);

      // 2. Filter Active
      filterNotifier.setFilter(TodoFilter.active);
      final activeList = container.read(filteredTodoListProvider);
      expect(activeList.length, 2);
      expect(activeList.every((t) => !t.done), isTrue);

      // 3. Filter Completed
      filterNotifier.setFilter(TodoFilter.completed);
      final completedList = container.read(filteredTodoListProvider);
      expect(completedList.length, 1);
      expect(completedList.first.title, 'Tugas Selesai 1');
    });
  });
}
