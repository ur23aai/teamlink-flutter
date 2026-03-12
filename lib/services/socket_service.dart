import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../config/api_config.dart';
import 'storage_service.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  final _storage = StorageService();
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  // Connect to socket
  Future<void> connect() async {
    // 🆕 Force disconnect first if already connected
    if (_socket != null) {
      print('🔌 Disconnecting existing socket');
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
    }

    final token = await _storage.getToken();
    if (token == null) {
      print('❌ No token found');
      return;
    }

    print('🔌 Connecting to socket: ${ApiConfig.socketUrl}');
    print('🔐 With token: ${token.substring(0, 20)}...');

    // disableAutoConnect so handlers are registered BEFORE the connection
    // opens — otherwise onConnect can fire before we've set it up and
    // join_chats is never emitted for that session.
    _socket = IO.io(
      ApiConfig.socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': token})
          .build(),
    );

    _socket!.onConnect((_) {
      print('✅ Socket connected!');
      _isConnected = true;
      _socket!.emit('join_chats', {});
    });

    _socket!.on('reconnect', (_) {
      print('🔄 Socket reconnected — re-joining chats');
      _isConnected = true;
      _socket!.emit('join_chats', {});
    });

    _socket!.on('chats_joined', (data) {
      print('✅ Joined ${data['count']} chats');
    });

    _socket!.onDisconnect((_) {
      print('❌ Socket disconnected');
      _isConnected = false;
    });

    _socket!.onError((error) {
      print('❌ Socket error: $error');
    });

    // Connect after all handlers are registered
    _socket!.connect();
  }


  // Listen for new messages
  void onNewMessage(Function(dynamic) callback) {
    _socket?.on('new_message', callback);
  }

  // Re-emit join_chats so the socket joins any newly created chat rooms
  void rejoinChats() {
    if (_socket != null && _isConnected) {
      print('🔄 Re-joining chats (for new chat room)');
      _socket!.emit('join_chats', {});
    }
  }

  // Explicitly join one specific chat room by its MongoDB _id
  void joinChat(String chatId) {
    if (_socket != null && _isConnected) {
      print('🚪 Joining specific chat room: $chatId');
      _socket!.emit('join_chat', {'chatId': chatId});
    }
  }

  // Send message
  void sendMessage(String chatId, String content) {
    if (_socket == null || !_socket!.connected) {
      print('❌ Socket not connected');
      return;
    }

    print('📤 Sending message to chat: $chatId');
    _socket!.emit('send_message', {
      'chatId': chatId,
      'content': content,
    });
  }

  // Send typing indicator
  void sendTyping(String chatId) {
    _socket?.emit('typing', {'chatId': chatId});
  }

  // Send stop typing
  void sendStopTyping(String chatId) {
    _socket?.emit('stop_typing', {'chatId': chatId});
  }

  // Listen for typing
  void onUserTyping(Function(dynamic) callback) {
    _socket?.on('user_typing', callback);
  }

  // Listen for stop typing
  void onUserStopTyping(Function(dynamic) callback) {
    _socket?.on('user_stop_typing', callback);
  }

  // Disconnect
  void disconnect() {
    print('🔌 Disconnecting socket');
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnected = false;
  }

  // Remove listeners
  void removeListener(String event) {
    _socket?.off(event);
  }
}
