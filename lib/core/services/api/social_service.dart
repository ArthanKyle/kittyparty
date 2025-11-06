import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../features/landing/model/socials.dart';


class SocialService {
  final String baseUrl;

  SocialService({String? baseUrl})
      : baseUrl = baseUrl ?? dotenv.env['BASE_URL']!;

  /// Fetch a user's social data (following, fans, friends, visitors)
  Future<Social?> fetchSocialData(int userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/socials/$userId'));

      print("[SocialService] GET /socials/$userId -> ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Social.fromJson(data);
      } else {
        print("[SocialService] Failed to fetch socials, body: ${response.body}");
      }
    } catch (e) {
      print("[SocialService] Exception fetching social data: $e");
    }
    return null;
  }

  /// Follow another user
  Future<bool> followUser(int userId, int targetId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/socials/follow'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'targetId': targetId,
        }),
      );

      print("[SocialService] POST /socials/follow -> ${response.statusCode}");

      return response.statusCode == 200;
    } catch (e) {
      print("[SocialService] Exception following user: $e");
      return false;
    }
  }

  /// Unfollow a user
  Future<bool> unfollowUser(int userId, int targetId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/socials/unfollow'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'targetId': targetId,
        }),
      );

      print("[SocialService] POST /socials/unfollow -> ${response.statusCode}");

      return response.statusCode == 200;
    } catch (e) {
      print("[SocialService] Exception unfollowing user: $e");
      return false;
    }
  }
}
