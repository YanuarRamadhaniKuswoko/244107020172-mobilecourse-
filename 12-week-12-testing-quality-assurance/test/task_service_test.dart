import 'package:flutter_test/flutter_test.dart';
import 'package:testing_lab/task_service.dart';

class FakeTaskRepository implements TaskRepository {
  FakeTaskRepository({this.tasks = const [], this.error});

  final List<String> tasks;
  final Exception? error;

  @override
  Future<List<String>> getTasks() async {
    if (error != null) throw error!;
    return tasks;
  }
}

void main() {
  group('TaskService', () {
    test('meneruskan data dari repository', () async {
      final service = TaskService(
        FakeTaskRepository(tasks: ['Baca materi']),
      );

      expect(await service.loadTasks(), ['Baca materi']);
    });

    test('melemparkan error saat repository gagal', () async {
      final service = TaskService(
        FakeTaskRepository(error: Exception('Gagal memuat tugas')),
      );

      expect(() => service.loadTasks(), throwsException);
    });
  });
}
