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
    if (_isLoading) return;
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final tasks = await _taskService.getMyTasks(
        status: status,
        priority: priority,
        teamId: teamId,
      );
      _tasks = tasks;
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
    if (_isLoading) return;
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final tasks = await _taskService.getTeamTasks(teamId);
      _tasks = tasks;
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
        await loadMyTasks();
        return true;
      } else {
        _errorMessage = result['message'];
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  // Update task (full edit)
  Future<bool> updateTask({
    required String taskId,
    String? title,
    String? description,
    String? priority,
    List<String>? assignedTo,
    DateTime? dueDate,
  }) async {
    try {
      final result = await _taskService.updateTask(
        taskId: taskId,
        title: title,
        description: description,
        priority: priority,
        assignedTo: assignedTo,
        dueDate: dueDate,
      );

      if (result['success']) {
        await loadMyTasks();
        return true;
      } else {
        _errorMessage = result['message'];
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
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
        await loadMyTasks();
        return true;
      } else {
        _errorMessage = result['message'];
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  // Delete task
  Future<bool> deleteTask(String taskId) async {
    try {
      final result = await _taskService.deleteTask(taskId);

      if (result['success']) {
        await loadMyTasks();
        return true;
      } else {
        _errorMessage = result['message'];
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  // Refresh tasks
  Future<void> refreshTasks() {
    return loadMyTasks();
  }

  // Clear tasks on logout
  void clearTasks() {
    _tasks = [];
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}