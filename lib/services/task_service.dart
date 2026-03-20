import '../models/task.dart';
import 'api_service.dart';

class TaskService {
  final _api = ApiService();

  // Get my tasks
  Future<List<Task>> getMyTasks({
    String? status,
    String? priority,
    String? teamId,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (status != null) params['status'] = status;
      if (priority != null) params['priority'] = priority;
      if (teamId != null) params['teamId'] = teamId;

      final response = await _api.get('/tasks', params: params);

      if (response.data['success'] == true) {
        final List<dynamic> tasksJson = response.data['data'];
        return tasksJson.map((json) => Task.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Get My Tasks Error: $e');
      return [];
    }
  }

  // Get team tasks
  Future<List<Task>> getTeamTasks(String teamId) async {
    try {
      final response = await _api.get('/tasks/team/$teamId/tasks');

      if (response.data['success'] == true) {
        final List<dynamic> tasksJson = response.data['data'];
        return tasksJson.map((json) => Task.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Get Team Tasks Error: $e');
      return [];
    }
  }

  // Create task
  Future<Map<String, dynamic>> createTask({
    required String title,
    String? description,
    required String teamId,
    List<String>? assignedTo,
    String? priority,
    String? status,
    DateTime? dueDate,
  }) async {
    try {
      final data = <String, dynamic>{
        'title': title,
        'teamId': teamId,
      };

      if (description != null && description.isNotEmpty) {
        data['description'] = description;
      }
      if (assignedTo != null && assignedTo.isNotEmpty) data['assignedTo'] = assignedTo;
      if (priority != null) data['priority'] = priority;
      if (status != null) data['status'] = status;
      if (dueDate != null) data['dueDate'] = dueDate.toIso8601String();

      final response = await _api.post('/tasks', data: data);

      if (response.data['success'] == true) {
        return {
          'success': true,
          'message': response.data['message'],
          'task': Task.fromJson(response.data['data']),
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to create task',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Update task
  Future<Map<String, dynamic>> updateTask({
    required String taskId,
    String? title,
    String? description,
    String? status,
    String? priority,
    List<String>? assignedTo,
    DateTime? dueDate,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (title != null) data['title'] = title;
      if (description != null) data['description'] = description;
      if (status != null) data['status'] = status;
      if (priority != null) data['priority'] = priority;
      if (assignedTo != null) data['assignedTo'] = assignedTo;
      if (dueDate != null) data['dueDate'] = dueDate.toIso8601String();

      final response = await _api.put('/tasks/$taskId', data: data);

      if (response.data['success'] == true) {
        return {
          'success': true,
          'message': response.data['message'],
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to update task',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Update task status
  Future<Map<String, dynamic>> updateTaskStatus({
    required String taskId,
    required String status,
  }) async {
    try {
      final response = await _api.patch(
        '/tasks/$taskId/status',
        data: {'status': status},
      );

      if (response.data['success'] == true) {
        return {
          'success': true,
          'message': response.data['message'],
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to update status',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Delete task
  Future<Map<String, dynamic>> deleteTask(String taskId) async {
    try {
      final response = await _api.delete('/tasks/$taskId');

      if (response.data['success'] == true) {
        return {
          'success': true,
          'message': response.data['message'],
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to delete task',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
}