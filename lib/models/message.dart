class Message {
  final String id;
  final String messageId;
  final String content;
  final String chatId;
  final MessageSender sender;
  final DateTime createdAt;
  final bool isMe;

  Message({
    required this.id,
    required this.messageId,
    required this.content,
    required this.chatId,
    required this.sender,
    required this.createdAt,
    this.isMe = false,
  });

  factory Message.fromJson(Map<String, dynamic> json, {String? currentUserId}) {
    final sender = MessageSender.fromJson(json['sender']);

    // Debug
    print(
        '🔍 Parsing message - Sender userId: ${sender.userId}, Current userId: $currentUserId');

    return Message(
      id: json['_id'] ?? '',
      messageId: json['messageId'] ?? '',
      content: json['content'] ?? '',
      chatId: json['chat'] is Map<String, dynamic>
          ? (json['chat'] as Map<String, dynamic>)['_id']?.toString() ?? ''
          : json['chat']?.toString() ?? '',
      sender: sender,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      isMe:
          currentUserId != null && sender.userId == currentUserId, // Check this
    );
  }
}

class MessageSender {
  final String userId;
  final String name;
  final String email;

  MessageSender({
    required this.userId,
    required this.name,
    required this.email,
  });

  factory MessageSender.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) {
      return MessageSender(userId: json?.toString() ?? '', name: 'Unknown', email: '');
    }
    return MessageSender(
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }
}
