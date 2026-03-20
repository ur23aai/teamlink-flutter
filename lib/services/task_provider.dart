import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/task_service.dart';

class TaskProvider extends ChangeNotifier {
  final _taskService = TaskService();

  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Get tasks by status
  List<Task> getTasksByStatus(String status) {
    return _tasks.where((task) => task.status == status).toList();
  }

  // Load my tasks
  Future<void> loadMyTasks({
    String? status,
    String? priority,
    String? teamId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _tasks = await _taskService.getMyTasks(
        status: status,
        priority: priority,
        teamId: teamId,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load team tasks
  Future<void> loadTeamTasks(String teamId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _tasks = await _taskService.getTeamTasks(teamId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create task
  Future<bool> createTask({
    required String title,
    String? description,
    required String teamId,
    List<String>? assignedTo,
    String? priority,
    String? status,
    DateTime? dueDate,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _taskService.createTask(
        title: title,
        description: description,
        teamId: teamId,
        assignedTo: assignedTo,
        priority: priority,
        status: status,
        dueDate: dueDate,
      );

      if (result['success']) {
        await loadMyTasks(); // Reload tasks
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update task status
  Future<bool> updateTaskStatus({
    required String taskId,
    required String status,
  }) async {
    try {
      final result = await _taskService.updateTaskStatus(
        taskId: taskId,
        status: status,
      );

      if (result['success']) {
        await loadMyTasks(); // Reload tasks
        return true;
      } else {
        _errorMessage = result['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Delete task
  Future<bool> deleteTask(String taskId) async {
    try {
      final result = await _taskService.deleteTask(taskId);

      if (result['success']) {
        await loadMyTasks(); // Reload tasks
        return true;
      } else {
        _errorMessage = result['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Refresh tasks
  Future<void> refreshTasks() async {
    await loadMyTasks();
  }
}