class User {
  final String id;
  final String userId;
  final String name;
  final String email;
  final DateTime createdAt;

  User({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'name': name,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}