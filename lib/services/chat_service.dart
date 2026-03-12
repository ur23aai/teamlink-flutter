import '../models/chat.dart';
import '../models/message.dart';
import 'api_service.dart';

class ChatService {
  final _api = ApiService();

  // Get my chats
  Future<List<Chat>> getMyChats() async {
    try {
      final response = await _api.get('/chats');

      if (response.data['success'] == true) {
        final List<dynamic> chatsJson = response.data['data'];
        return chatsJson.map((json) => Chat.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Get Chats Error: $e');
      return [];
    }
  }

  // Get or create team chat
  Future<Chat?> getOrCreateTeamChat(String teamId) async {
    try {
      final response = await _api.post(
        '/chats/team',
        data: {'teamId': teamId},
      );

      if (response.data['success'] == true) {
        return Chat.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      print('Get Team Chat Error: $e');
      return null;
    }
  }

  // Get or create direct chat
  Future<Chat?> getOrCreateDirectChat(String userId) async {
    try {
      final response = await _api.post(
        '/chats/direct',
        data: {'userId': userId},
      );

      if (response.data['success'] == true) {
        return Chat.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      print('Get Direct Chat Error: $e');
      return null;
    }
  }

  // Get chat messages
  Future<List<Message>> getChatMessages(String chatId, String currentUserId) async {
    try {
      final response = await _api.get('/chats/$chatId/messages');

      if (response.data['success'] == true) {
        final List<dynamic> messagesJson = response.data['data'];
        return messagesJson
            .map((json) => Message.fromJson(json, currentUserId: currentUserId))
            .toList();
      }
      return [];
    } catch (e) {
      print('Get Messages Error: $e');
      return [];
    }
  }

  // Send message (REST API fallback)
  Future<bool> sendMessage(String chatId, String content) async {
    try {
      final response = await _api.post(
        '/chats/$chatId/messages',
        data: {'content': content},
      );

      return response.data['success'] == true;
    } catch (e) {
      print('Send Message Error: $e');
      return false;
    }
  }

  // Mark messages as read
  Future<bool> markAsRead(String chatId) async {
    try {
      final response = await _api.patch('/chats/$chatId/read');
      return response.data['success'] == true;
    } catch (e) {
      print('Mark Read Error: $e');
      return false;
    }
  }
}