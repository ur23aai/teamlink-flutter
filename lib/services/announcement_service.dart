import '../models/announcement.dart';
import 'api_service.dart';

class AnnouncementService {
  final _api = ApiService();


// Get team announcements
Future<List<Announcement>> getTeamAnnouncements(String teamMongoId) async {
  try {
    // Use the MongoDB _id directly in the URL
    final response = await _api.get('/teams/$teamMongoId/announcements');

    if (response.data['success'] == true) {
      final List<dynamic> announcementsJson = response.data['data'];
      return announcementsJson
          .map((json) => Announcement.fromJson(json))
          .toList();
    }
    return [];
  } catch (e) {
    print('Get Announcements Error: $e');
    return [];
  }
}

  // Create announcement (Admin only)
  Future<Map<String, dynamic>> createAnnouncement({
    required String teamId,
    required String title,
    required String message,
  }) async {
    try {
      final response = await _api.post(
        '/teams/$teamId/announcements',
        data: {
          'title': title,
          'message': message,
        },
      );

      if (response.data['success'] == true) {
        return {
          'success': true,
          'message': response.data['message'],
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to create announcement',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Delete announcement (Admin only)
  Future<bool> deleteAnnouncement(String announcementId) async {
    try {
      final response = await _api.delete('/announcements/$announcementId');
      return response.data['success'] == true;
    } catch (e) {
      print('Delete Announcement Error: $e');
      return false;
    }
  }
}