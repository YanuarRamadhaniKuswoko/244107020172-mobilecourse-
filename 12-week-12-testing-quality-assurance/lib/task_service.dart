abstract interface class TaskRepository {
  Future<List<String>> getTasks();
}

class TaskService {
  TaskService(this._repository);

  final TaskRepository _repository;

  Future<List<String>> loadTasks() {
    return _repository.getTasks();
  }
}
