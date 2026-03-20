class Task {
  final String id;
  final String taskId;
  final String title;
  final String? description;
  final String status; // 'To Do', 'In Progress', 'Completed'
  final String priority; // 'Low', 'Medium', 'High'
  final DateTime? dueDate;
  final String teamId;
  final String teamName;
  final List<AssignedUser> assignedTo;
  final AssignedUser createdBy;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.taskId,
    required this.title,
    this.description,
    required this.status,
    required this.priority,
    this.dueDate,
    required this.teamId,
    required this.teamName,
    this.assignedTo = const [],
    required this.createdBy,
    required this.createdAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['_id'] ?? '',
      taskId: json['taskId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      status: json['status'] ?? 'To Do',
      priority: json['priority'] ?? 'Medium',
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      teamId: json['team']?['teamId'] ?? '',
      teamName: json['team']?['name'] ?? '',
      assignedTo: json['assignedTo'] != null
          ? (json['assignedTo'] as List)
              .map((u) => AssignedUser.fromJson(u))
              .toList()
          : [],
      createdBy: AssignedUser.fromJson(json['createdBy']),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'taskId': taskId,
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      'dueDate': dueDate?.toIso8601String(),
      'teamId': teamId,
      'teamName': teamName,
      'assignedTo': assignedTo.map((u) => u.toJson()).toList(),
      'createdBy': createdBy.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class AssignedUser {
  final String userId;
  final String name;
  final String email;

  AssignedUser({
    required this.userId,
    required this.name,
    required this.email,
  });

  factory AssignedUser.fromJson(Map<String, dynamic> json) {
    return AssignedUser(
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
    };
  }
}