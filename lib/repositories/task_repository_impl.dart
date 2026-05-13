import 'package:sqflite/sqflite.dart';

import '../helpers/database_helper.dart';
import '../models/task.dart';
import 'task_repository.dart';

/// Concrete implementation of [TaskRepositoryBase] backed by SQLite.
class TaskRepositoryImpl implements TaskRepositoryBase {
  final DatabaseHelper _dbHelper;

  TaskRepositoryImpl({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  @override
  Future<int> insertTask(Task task) async {
    return await _dbHelper.insertTask(task);
  }

  @override
  Future<List<Task>> getTasks() async {
    return await _dbHelper.getAllTasks();
  }

  @override
  Future<int> toggleTaskStatus(Task task) async {
    if (task.id == null) return 0;
    return await _dbHelper.toggleTaskCompletion(task.id!, !task.isCompleted);
  }

  @override
  Future<int> updateTask(Task task) async {
    return await _dbHelper.updateTask(task);
  }

  @override
  Future<int> softDeleteTask(Task task) async {
    final deletedTask = task.copyWith(isDeleted: true);
    return await _dbHelper.updateTask(deletedTask);
  }

  @override
  Future<int> getCompletedTaskCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM tasks WHERE is_completed = 1 AND is_deleted = 0');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  @override
  Future<int> getPendingTaskCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM tasks WHERE is_completed = 0 AND is_deleted = 0');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  @override
  Future<Map<String, int>> getCompletedTasksPerDay() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT due_date, COUNT(*) as count 
      FROM tasks 
      WHERE is_completed = 1 AND due_date IS NOT NULL AND is_deleted = 0
      GROUP BY due_date
      ORDER BY due_date ASC
    ''');

    Map<String, int> tasksPerDay = {};
    for (var row in result) {
      tasksPerDay[row['due_date'] as String] = row['count'] as int;
    }
    return tasksPerDay;
  }
}
