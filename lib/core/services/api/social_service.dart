import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../features/landing/model/friend_user.dart';
import '../../../features/landing/model/socials.dart';

class SocialService {
  final String baseUrl;

  SocialService({String? baseUrl})
      : baseUrl = baseUrl ?? dotenv.env['BASE_URL']!;

  Future<Social> fetchSocialData(String userId) async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/socials/$userId'));
      if (res.statusCode == 200) {
        return Social.fromJson(jsonDecode(res.body));
      }
    } catch (_) {}
    return _emptySocial(userId);
  }

  Future<void> followUser({
    required String userId,
    required String targetId,
  }) async {
    await http.post(
      Uri.parse('$baseUrl/socials/follow'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId, 'targetId': targetId}),
    );
  }

  Future<List<FriendUser>> fetchFriends(String userId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/socials/friends/$userId'),
    );

    if (res.statusCode != 200) return [];

    final list = jsonDecode(res.body) as List;
    return list.map((e) => FriendUser.fromJson(e)).toList();
  }

  Future<void> unfollowUser({
    required String userId,
    required String targetId,
  }) async {
    await http.post(
      Uri.parse('$baseUrl/socials/unfollow'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId, 'targetId': targetId}),
    );
  }

  Future<void> addFriend({
    required String userId,
    required String targetId,
  }) async {
    await http.post(
      Uri.parse('$baseUrl/socials/add-friend'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId, 'targetId': targetId}),
    );
  }

  Future<void> unfriendUser({
    required String userId,
    required String targetId,
  }) async {
    await http.post(
      Uri.parse('$baseUrl/socials/unfriend'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId, 'targetId': targetId}),
    );
  }

  /// 🔥 single source of truth
  Future<bool> isFollowing({
    required String userId,
    required String targetId,
  }) async {
    final res = await http.get(
      Uri.parse('$baseUrl/socials/is-following/$userId/$targetId'),
    );
    if (res.statusCode != 200) return false;
    return jsonDecode(res.body)['isFollowing'] == true;
  }

  /// ✅ FRIEND = MUTUAL FOLLOW
  Future<bool> isFriend({
    required String userId,
    required String targetId,
  }) async {
    final a = await isFollowing(userId: userId, targetId: targetId);
    final b = await isFollowing(userId: targetId, targetId: userId);
    return a && b;
  }

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
