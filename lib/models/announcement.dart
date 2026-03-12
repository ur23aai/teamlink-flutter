class Announcement {
  final String id;
  final String announcementId;
  final String title;
  final String message;
  final String teamId;
  final String teamName;
  final Creator createdBy;
  final DateTime createdAt;

  Announcement({
    required this.id,
    required this.announcementId,
    required this.title,
    required this.message,
    required this.teamId,
    required this.teamName,
    required this.createdBy,
    required this.createdAt,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['_id'] ?? '',
      announcementId: json['announcementId'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      teamId: json['team']?['teamId'] ?? '',
      teamName: json['team']?['name'] ?? '',
      createdBy: Creator.fromJson(json['createdBy'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class Creator {
  final String userId;
  final String name;
  final String email;

  Creator({
    required this.userId,
    required this.name,
    required this.email,
  });

  factory Creator.fromJson(Map<String, dynamic> json) {
    return Creator(
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }
}