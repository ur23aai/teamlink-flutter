import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final _secureStorage = const FlutterSecureStorage();
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Token Management (Secure)
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: 'auth_token', value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }

  Future<void> deleteToken() async {
    await _secureStorage.delete(key: 'auth_token');
  }

  // User Data
  Future<void> saveUserId(String userId) async {
    await _prefs?.setString('user_id', userId);
  }

  String? getUserId() {
    return _prefs?.getString('user_id');
  }

  Future<void> saveUserName(String name) async {
    await _prefs?.setString('user_name', name);
  }

  String? getUserName() {
    return _prefs?.getString('user_name');
  }

  Future<void> saveUserEmail(String email) async {
    await _prefs?.setString('user_email', email);
  }

  String? getUserEmail() {
    return _prefs?.getString('user_email');
  }

  // Clear all data
  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
    await _prefs?.clear();
  }

  // Check if logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
