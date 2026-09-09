/// Model representing task statistics for the dashboard/analytics page.
class TaskStats {
  const TaskStats({
    required this.totalTasks,
    required this.completedTasks,
    required this.pendingTasks,
    required this.categories,
  });

  final int totalTasks;
  final int completedTasks;
  final int pendingTasks;
  final List<String> categories;

  double get completionRate =>
      totalTasks == 0 ? 0.0 : (completedTasks / totalTasks) * 100.0;
}
