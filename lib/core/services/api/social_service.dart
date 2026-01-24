import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../features/landing/model/socials.dart';

class SocialService {
  final String baseUrl;

  SocialService({String? baseUrl})
      : baseUrl = baseUrl ?? dotenv.env['BASE_URL']!;

  /// Fetch a user's social data
  Future<Social> fetchSocialData(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/socials/$userId'),
      );

      if (response.statusCode == 200) {
        return Social.fromJson(jsonDecode(response.body));
      }

      return _emptySocial(userId);
    } catch (_) {
      return _emptySocial(userId);
    }
  }

  /// Follow another user
  Future<void> followUser({
    required String userId,
    required String targetId,
  }) async {
    await http.post(
      Uri.parse('$baseUrl/socials/follow'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'targetId': targetId,
      }),
    );
  }

  /// Unfollow another user
  Future<void> unfollowUser({
    required String userId,
    required String targetId,
  }) async {
    await http.post(
      Uri.parse('$baseUrl/socials/unfollow'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'targetId': targetId,
      }),
    );
  }

  /// Add friend (mutual)
  Future<void> addFriend({
    required String userId,
    required String targetId,
  }) async {
    await http.post(
      Uri.parse('$baseUrl/socials/add-friend'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'targetId': targetId,
      }),
    );
  }

  /// 🔥 CHECK FOLLOW RELATION (TRUTH)
  Future<bool> isFollowing({
    required String userId,
    required String targetId,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/socials/is-following/$userId/$targetId'),
    );

    if (response.statusCode != 200) return false;

    final data = jsonDecode(response.body);
    return data['isFollowing'] == true;
  }

  /// Unfriend
  Future<void> unfriendUser({
    required String userId,
    required String targetId,
  }) async {
    await http.post(
      Uri.parse('$baseUrl/socials/unfriend'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'targetId': targetId,
      }),
    );
  }

  // ---------------- helper ----------------
  Social _emptySocial(String userId) {
    return Social(
      user: userId,
      following: 0,
      fans: 0,
      friends: 0,
      visitors: 0,
    );
  }
}
