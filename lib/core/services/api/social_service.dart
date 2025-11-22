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

      print("🔍 Raw Response (${response.statusCode}): ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print('📌 Parsed Social Data: $data');
        return Social.fromJson(data);
      } else if (response.statusCode == 404) {
        print('⚠️ Social data not found, returning default zeros');
        return Social(
          user: userId,
          following: 0,
          fans: 0,
          friends: 0,
          visitors: 0,
        );
      } else {
        print('⚠️ Failed to load social data. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Social API Error: $e');
      return Social(
        user: userId,
        following: 0,
        fans: 0,
        friends: 0,
        visitors: 0,
      );
    }
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
      print("🔍 Raw Response (${response.statusCode}): ${response.body}");

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
      print("🔍 Raw Response (${response.statusCode}): ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      print("[SocialService] Exception unfollowing user: $e");
      return false;
    }
  }
}
