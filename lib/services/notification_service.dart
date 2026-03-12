import '../models/notification.dart';
import 'api_service.dart';

class NotificationService {
  final _api = ApiService();

  // Get my notifications
  Future<Map<String, dynamic>> getMyNotifications({bool? isRead}) async {
    try {
      final params = <String, dynamic>{};
      if (isRead != null) params['isRead'] = isRead.toString();

      final response = await _api.get('/notifications', params: params);

      if (response.data['success'] == true) {
        final List<dynamic> notificationsJson = response.data['data'];
        final notifications = notificationsJson
            .map((json) => AppNotification.fromJson(json))
            .toList();

        return {
          'success': true,
          'notifications': notifications,
          'unreadCount': response.data['unreadCount'] ?? 0,
        };
      }
      return {
        'success': false,
        'notifications': <AppNotification>[],
        'unreadCount': 0,
      };
    } catch (e) {
      print('Get Notifications Error: $e');
      return {
        'success': false,
        'notifications': <AppNotification>[],
        'unreadCount': 0,
      };
    }
  }

  // Mark as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      final response = await _api.patch('/notifications/$notificationId/read');
      return response.data['success'] == true;
    } catch (e) {
      print('Mark Read Error: $e');
      return false;
    }
  }

  // Mark all as read
  Future<bool> markAllAsRead() async {
    try {
      final response = await _api.patch('/notifications/read-all');
      return response.data['success'] == true;
    } catch (e) {
      print('Mark All Read Error: $e');
      return false;
    }
  }

  // Delete notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      final response = await _api.delete('/notifications/$notificationId');
      return response.data['success'] == true;
    } catch (e) {
      print('Delete Notification Error: $e');
      return false;
    }
  }

  // Clear read notifications
  Future<bool> clearReadNotifications() async {
    try {
      final response = await _api.delete('/notifications/clear-read');
      return response.data['success'] == true;
    } catch (e) {
      print('Clear Read Error: $e');
      return false;
    }
  }
}