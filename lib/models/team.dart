class Team {
  final String id;
  final String teamId;
  final String name;
  final String? description;
  final String joinCode;
  final String role; // 'Admin' or 'Member'
  final int memberCount;
  final DateTime joinedAt;

  Team({
    required this.id,
    required this.teamId,
    required this.name,
    this.description,
    required this.joinCode,
    required this.role,
    required this.memberCount,
    required this.joinedAt,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['_id'] ?? '',
      teamId: json['teamId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      joinCode: json['joinCode'] ?? '',
      role: json['role'] ?? 'Member',
      memberCount: json['memberCount'] ?? 0,
      joinedAt: DateTime.parse(json['joinedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'teamId': teamId,
      'name': name,
      'description': description,
      'joinCode': joinCode,
      'role': role,
      'memberCount': memberCount,
      'joinedAt': joinedAt.toIso8601String(),
    };
  }
}

class TeamMember {
  final String membershipId;
  final String userId;
  final String name;
  final String email;
  final String role;
  final DateTime joinedAt;

  TeamMember({
    required this.membershipId,
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    required this.joinedAt,
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      membershipId: json['membershipId'] ?? '',
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'Member',
      joinedAt: DateTime.parse(json['joinedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}