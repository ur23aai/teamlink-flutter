import '../models/team.dart';
import 'api_service.dart';

class TeamService {
  final _api = ApiService();

  // Get my teams
  Future<List<Team>> getMyTeams() async {
    try {
      final response = await _api.get('/teams');
      
      if (response.data['success'] == true) {
        final List<dynamic> teamsJson = response.data['data'];
        return teamsJson.map((json) => Team.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Get Teams Error: $e');
      return [];
    }
  }

  // Create team
  Future<Map<String, dynamic>> createTeam({
    required String name,
    String? description,
  }) async {
    try {
      final response = await _api.post(
        '/teams',
        data: {
          'name': name,
          'description': description,
        },
      );

      if (response.data['success'] == true) {
        return {
          'success': true,
          'message': response.data['message'],
          'team': Team.fromJson(response.data['data']),
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to create team',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Join team via code
  Future<Map<String, dynamic>> joinTeam(String joinCode) async {
    try {
      final response = await _api.post(
        '/teams/join',
        data: {'joinCode': joinCode.toUpperCase()},
      );

      if (response.data['success'] == true) {
        return {
          'success': true,
          'message': response.data['message'],
          'data': response.data['data'],
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to join team',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Get team members
  Future<List<TeamMember>> getTeamMembers(String teamId) async {
    try {
      final response = await _api.get('/teams/$teamId/members');
      
      if (response.data['success'] == true) {
        final List<dynamic> membersJson = response.data['data'];
        return membersJson.map((json) => TeamMember.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Get Team Members Error: $e');
      return [];
    }
  }

  // Add member by email (Admin only)
  Future<Map<String, dynamic>> addMember({
    required String teamId,
    required String email,
  }) async {
    try {
      final response = await _api.post(
        '/teams/$teamId/members',
        data: {'email': email},
      );

      if (response.data['success'] == true) {
        return {
          'success': true,
          'message': response.data['message'],
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to add member',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Remove member (Admin only)
  Future<Map<String, dynamic>> removeMember({
    required String teamId,
    required String userId,
  }) async {
    try {
      final response = await _api.delete('/teams/$teamId/members/$userId');

      if (response.data['success'] == true) {
        return {
          'success': true,
          'message': response.data['message'],
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to remove member',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Update team (Admin only)
  Future<Map<String, dynamic>> updateTeam({
    required String teamId,
    String? name,
    String? description,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (description != null) data['description'] = description;

      final response = await _api.put('/teams/$teamId', data: data);

      if (response.data['success'] == true) {
        return {
          'success': true,
          'message': response.data['message'],
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to update team',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Search users by name or email
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      final response = await _api.get('/users/search', params: {'query': query});
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((u) => Map<String, dynamic>.from(u)).toList();
      }
      return [];
    } catch (e) {
      print('Search Users Error: $e');
      return [];
    }
  }

  // Delete team (Admin only)
  Future<Map<String, dynamic>> deleteTeam(String teamId) async {
    try {
      final response = await _api.delete('/teams/$teamId');

      if (response.data['success'] == true) {
        return {
          'success': true,
          'message': response.data['message'],
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to delete team',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
}