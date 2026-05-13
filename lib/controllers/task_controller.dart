import 'package:flutter/foundation.dart';

import '../models/task.dart';
import '../repositories/task_repository.dart';
import '../services/notification_service.dart';

/// Manages task-related state.
class TaskController extends ChangeNotifier {
  final TaskRepositoryBase _repository;

  TaskController({required TaskRepositoryBase repository})
      : _repository = repository;

  bool _isLoading = false;
  String? _errorMessage;
  List<Task> _tasks = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Task> get tasks => _tasks;

  /// Fetches all tasks from the repository.
  Future<void> fetchTasks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _tasks = await _repository.getTasks();
    } catch (e) {
      _errorMessage = 'Gagal memuat daftar tugas: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Adds a new task to the database.
  Future<bool> addTask(Task task) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final id = await _repository.insertTask(task);
      final savedTask = task.copyWith(id: id);
      
      // Schedule notifications
      await NotificationService.instance.scheduleTaskNotifications(savedTask);
      
      await fetchTasks(); // Refresh list after adding
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menyimpan tugas: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Toggles the completion status of a task.
  Future<bool> toggleTaskStatus(Task task) async {
    try {
      final success = await _repository.toggleTaskStatus(task);
      if (success > 0) {
        await fetchTasks(); // Refresh list to reflect changes
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Gagal mengupdate status: $e';
      notifyListeners();
      return false;
    }
  }

  /// Updates an existing task's details.
  Future<bool> updateTask(Task task) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final rows = await _repository.updateTask(task);
      if (rows > 0) {
        await fetchTasks();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Gagal mengedit tugas: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Soft deletes a task.
  Future<bool> softDeleteTask(Task task) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final rows = await _repository.softDeleteTask(task);
      if (rows > 0) {
        await fetchTasks();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Gagal menghapus tugas: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }
}
