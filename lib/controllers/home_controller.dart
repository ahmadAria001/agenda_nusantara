import 'package:flutter/foundation.dart';

import '../repositories/task_repository.dart';

/// Manages the state for the Home Screen dashboard (metrics and charts).
class HomeController extends ChangeNotifier {
  final TaskRepositoryBase _repository;

  HomeController({required TaskRepositoryBase repository})
      : _repository = repository;

  bool _isLoading = false;
  String? _errorMessage;

  int _completedCount = 0;
  int _pendingCount = 0;
  Map<String, int> _completedTasksPerDay = {};

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get completedCount => _completedCount;
  int get pendingCount => _pendingCount;
  Map<String, int> get completedTasksPerDay => _completedTasksPerDay;

  /// Fetches all dashboard metrics from the repository.
  Future<void> fetchDashboardMetrics() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _completedCount = await _repository.getCompletedTaskCount();
      _pendingCount = await _repository.getPendingTaskCount();
      _completedTasksPerDay = await _repository.getCompletedTasksPerDay();
    } catch (e) {
      _errorMessage = 'Gagal memuat data dashboard: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
