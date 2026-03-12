import 'package:flutter/material.dart';
import '../models/chat.dart';
import '../models/message.dart';
import '../services/chat_service.dart';
import '../services/socket_service.dart';
import '../services/storage_service.dart';

class ChatProvider extends ChangeNotifier {
  final _chatService = ChatService();
  final _socketService = SocketService();
  final _storage = StorageService();

  List<Chat> _chats = [];
  List<Message> _currentMessages = [];
  Chat? _currentChat;
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentUserId;

  List<Chat> get chats => _chats;
  List<Message> get currentMessages => _currentMessages;
  Chat? get currentChat => _currentChat;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

// Initialize socket connection
  Future<void> initSocket() async {
    // 🆕 ALWAYS get fresh user ID
    _currentUserId = _storage.getUserId();
    print('🔐 ChatProvider initialized with user ID: $_currentUserId');

    // Disconnect existing connection first
    _socketService.disconnect();

    // Small delay to ensure clean reconnect
    await Future.delayed(const Duration(milliseconds: 500));

    // Connect with fresh token
    await _socketService.connect();

    // Listen for new messages
    _socketService.onNewMessage((data) {
      print('📨 New message received in provider');

      try {
        // 🆕 ALWAYS get fresh current user ID
        final currentUserId = _storage.getUserId();
        print('🔍 Current user ID (fresh): $currentUserId');

        final message = Message.fromJson(
          data['message'],
          currentUserId: currentUserId,
        );

        print(
            '📩 Message sender: ${message.sender.userId}, isMe: ${message.isMe}');

        // Add to current messages if in the same chat
        if (_currentChat != null && message.chatId == _currentChat!.id) {
          print('✅ Adding message to current chat');
          _currentMessages = [..._currentMessages, message];
          notifyListeners();
        }

        // Reload chats to update last message
        loadChats();
      } catch (e) {
        print('❌ Error parsing message: $e');
      }
    });
  }

  // Clear chats on logout
  void clearChats() {
    _chats = [];
    _currentMessages = [];
    _currentChat = null;
    _isLoading = false;
    _errorMessage = null;
    _currentUserId = null;

    // Disconnect socket
    _socketService.disconnect();

    notifyListeners();
  }

  // Load chats
  Future<void> loadChats() async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      _chats = await _chatService.getMyChats();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Open chat
  // Load messages
  Future<void> openChat(Chat chat) async {
    _currentChat = chat;
    _currentMessages = [];
    _isLoading = true;
    notifyListeners();

    // Explicitly join this specific chat room, then also rejoin all rooms.
    // joinChat targets this room immediately; rejoinChats handles the rest.
    _socketService.joinChat(chat.id);
    _socketService.rejoinChats();

    try {
      final userId = _storage.getUserId() ?? '';
      print('🔍 Current user ID: $userId'); // 🆕 ADD DEBUG

      _currentMessages = await _chatService.getChatMessages(chat.id, userId);

      // 🆕 ADD DEBUG - Check message sender IDs
      for (var msg in _currentMessages) {
        print('Message from: ${msg.sender.userId}, isMe: ${msg.isMe}');
      }

      // Mark as read
      await _chatService.markAsRead(chat.id);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Send message via socket
  void sendMessage(String content) {
    if (_currentChat == null) return;

    _socketService.sendMessage(_currentChat!.id, content);

    // Optimistically add to UI (will be replaced by socket event)
    // This gives instant feedback
  }

  // Send typing indicator
  void sendTyping() {
    if (_currentChat != null) {
      _socketService.sendTyping(_currentChat!.id);
    }
  }

  // Send stop typing
  void sendStopTyping() {
    if (_currentChat != null) {
      _socketService.sendStopTyping(_currentChat!.id);
    }
  }

  // Get or create team chat
  Future<Chat?> getOrCreateTeamChat(String teamId) async {
    try {
      final chat = await _chatService.getOrCreateTeamChat(teamId);
      if (chat != null) {
        // Re-join all chats so the socket enters the newly created room
        _socketService.rejoinChats();
        await loadChats();
      }
      return chat;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    }
  }

  // Close current chat
  void closeChat() {
    _currentChat = null;
    _currentMessages = [];
    notifyListeners();
  }

  // Refresh
  Future<void> refresh() {
    return loadChats();
  }

  @override
  void dispose() {
    clearChats(); // Use the clear method
    super.dispose();
  }
}
