import 'package:flutter/material.dart';
import '../models/notification.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final _notificationService = NotificationService();

  List<AppNotification> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _errorMessage;

  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load notifications
  Future<void> loadNotifications({bool? isRead}) async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _notificationService.getMyNotifications(
        isRead: isRead,
      );

      if (result['success']) {
        _notifications = result['notifications'];
        _unreadCount = result['unreadCount'];
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mark as read
  Future<bool> markAsRead(String notificationId) async {
    final success = await _notificationService.markAsRead(notificationId);
    if (success) {
      await loadNotifications();
    }
    return success;
  }

  // Mark all as read
  Future<bool> markAllAsRead() async {
    final success = await _notificationService.markAllAsRead();
    if (success) {
      await loadNotifications();
    }
    return success;
  }

  // Delete notification
  Future<bool> deleteNotification(String notificationId) async {
    final success =
        await _notificationService.deleteNotification(notificationId);
    if (success) {
      await loadNotifications();
    }
    return success;
  }

  // Clear read notifications
  Future<bool> clearReadNotifications() async {
    final success = await _notificationService.clearReadNotifications();
    if (success) {
      await loadNotifications();
    }
    return success;
  }

  // Refresh
  Future<void> refresh() {
    return loadNotifications();
  }

  // Clear notifications on logout
  void clearNotifications() {
    _notifications = [];
    _unreadCount = 0;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
