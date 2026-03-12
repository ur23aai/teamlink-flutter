class Chat {
  final String id;
  final String chatId;
  final String? chatName;
  final String chatType; // 'team' or 'direct'
  final String? teamId;
  final String? teamName;
  final List<ChatParticipant> participants;
  final LastMessage? lastMessage;
  final int unreadCount;

  Chat({
    required this.id,
    required this.chatId,
    this.chatName,
    required this.chatType,
    this.teamId,
    this.teamName,
    required this.participants,
    this.lastMessage,
    this.unreadCount = 0,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    // Backend may return `team` as a populated object OR as a raw string ID
    final teamData = json['team'];
    String? teamId;
    String? teamName;
    if (teamData is Map<String, dynamic>) {
      teamId = teamData['teamId']?.toString() ?? teamData['_id']?.toString();
      teamName = teamData['name']?.toString();
    } else if (teamData is String) {
      teamId = teamData;
    }

    return Chat(
      id: json['_id'] ?? '',
      chatId: json['chatId'] ?? '',
      chatName: json['chatName'],
      chatType: json['chatType'] ?? 'direct',
      teamId: teamId,
      teamName: teamName,
      participants: json['participants'] != null
          ? (json['participants'] as List)
              .whereType<Map<String, dynamic>>()
              .map((p) => ChatParticipant.fromJson(p))
              .toList()
          : [],
      lastMessage: json['lastMessage'] != null
          ? LastMessage.fromJson(json['lastMessage'])
          : null,
      unreadCount: json['unreadCount'] ?? 0,
    );
  }
}

class ChatParticipant {
  final String userId;
  final String name;
  final String email;

  ChatParticipant({
    required this.userId,
    required this.name,
    required this.email,
  });

  factory ChatParticipant.fromJson(Map<String, dynamic> json) {
    return ChatParticipant(
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

class LastMessage {
  final String content;
  final Sender sender;
  final DateTime createdAt;

  LastMessage({
    required this.content,
    required this.sender,
    required this.createdAt,
  });

  factory LastMessage.fromJson(Map<String, dynamic> json) {
    final senderData = json['sender'];
    return LastMessage(
      content: json['content'] ?? '',
      sender: senderData is Map<String, dynamic>
          ? Sender.fromJson(senderData)
          : Sender(name: 'Unknown'),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class Sender {
  final String name;

  Sender({required this.name});

  factory Sender.fromJson(Map<String, dynamic> json) {
    return Sender(name: json['name'] ?? 'Unknown');
  }
}