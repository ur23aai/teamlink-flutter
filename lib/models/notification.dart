class AppNotification {
  final String id;
  final String notificationId;
  final String type;
  final String message;
  final String? relatedId;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.notificationId,
    required this.type,
    required this.message,
    this.relatedId,
    required this.isRead,
    this.readAt,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['_id'] ?? '',
      notificationId: json['notificationId'] ?? '',
      type: json['type'] ?? '',
      message: json['message'] ?? '',
      relatedId: json['relatedId'],
      isRead: json['isRead'] ?? false,
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
