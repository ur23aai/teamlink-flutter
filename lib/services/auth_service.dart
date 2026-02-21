import '../config/api_config.dart';
import '../models/user.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  final _api = ApiService();
  final _storage = StorageService();

  // Register
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _api.post(
        '/auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
        },
      );

      if (response.data['success'] == true) {
        // Save token
        final token = response.data['token'];
        await _storage.saveToken(token);

        // Save user data
        final userData = response.data['data'];
        await _storage.saveUserId(userData['userId']);
        await _storage.saveUserName(userData['name']);
        await _storage.saveUserEmail(userData['email']);

        return {
          'success': true,
          'message': response.data['message'],
          'user': User.fromJson(userData),
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Registration failed',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _api.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.data['success'] == true) {
        // Save token
        final token = response.data['token'];
        await _storage.saveToken(token);

        // Save user data
        final userData = response.data['data'];
        await _storage.saveUserId(userData['userId']);
        await _storage.saveUserName(userData['name']);
        await _storage.saveUserEmail(userData['email']);

        return {
          'success': true,
          'message': 'Login successful',
          'user': User.fromJson(userData),
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Login failed',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Get current user
  Future<User?> getCurrentUser() async {
    try {
      final response = await _api.get('/auth/me');

      if (response.data['success'] == true) {
        return User.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Update profile
  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? email,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (email != null) data['email'] = email;

      final response = await _api.put('/auth/profile', data: data);

      if (response.data['success'] == true) {
        // Update stored user data
        final userData = response.data['data'];
        if (name != null) await _storage.saveUserName(userData['name']);
        if (email != null) await _storage.saveUserEmail(userData['email']);

        return {
          'success': true,
          'message': response.data['message'],
          'user': User.fromJson(userData),
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Update failed',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Logout
  Future<void> logout() async {
    await _storage.clearAll();
  }

  // Check if logged in
  Future<bool> isLoggedIn() async {
    return await _storage.isLoggedIn();
  }
}