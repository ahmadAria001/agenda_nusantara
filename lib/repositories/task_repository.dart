import '../models/task.dart';

/// Abstract contract for task-related operations (DIP).
abstract class TaskRepositoryBase {
  /// Inserts a new [Task] into the database.
  /// Returns the generated ID of the new task.
  Future<int> insertTask(Task task);

  /// Retrieves all tasks from the database.
  Future<List<Task>> getTasks();

  /// Toggles the completion status of the given [task].
  /// Returns the number of rows affected.
  Future<int> toggleTaskStatus(Task task);

  /// Updates the details of an existing [task].
  /// Returns the number of rows affected.
  Future<int> updateTask(Task task);

  /// Soft-deletes the given [task] by marking it as deleted.
  /// Returns the number of rows affected.
  Future<int> softDeleteTask(Task task);

  /// Gets the total number of completed tasks.
  Future<int> getCompletedTaskCount();

  /// Gets the total number of pending tasks.
  Future<int> getPendingTaskCount();

  /// Gets the number of completed tasks grouped by date.
  /// Returns a map where the key is the date string and value is the count.
  Future<Map<String, int>> getCompletedTasksPerDay();
}
