import 'package:flutter/cupertino.dart';
import '../../../core/services/api/social_service.dart';
import '../model/socials.dart';

class SocialViewModel extends ChangeNotifier {
  final _service = SocialService();

  Social? social;

  bool isFollowing = false;
  bool isFriend = false;
  bool isLoading = false;

  late String _currentUserId;
  late String _targetUserId;

  // ---------------- LOAD ----------------
  Future<void> load({
    required String currentUserId,
    required String targetUserId,
  }) async {
    _currentUserId = currentUserId;
    _targetUserId = targetUserId;

    social = await _service.fetchSocialData(targetUserId);

    // TEMP inference (backend has no relationship endpoint yet)
    isFriend = (social?.friends ?? 0) > 0;
    isFollowing = false;

    notifyListeners();
  }

  // ---------------- FOLLOW ----------------
  Future<void> follow() async {
    if (isLoading) return;
    isLoading = true;

    isFollowing = true;
    notifyListeners();

    await _service.followUser(
      userId: _currentUserId,
      targetId: _targetUserId,
    );

    await refresh();
    isLoading = false;
  }

  // ---------------- UNFOLLOW ----------------
  Future<void> unfollow() async {
    if (isLoading) return;
    isLoading = true;

    isFollowing = false;
    notifyListeners();

    await _service.unfollowUser(
      userId: _currentUserId,
      targetId: _targetUserId,
    );

    await refresh();
    isLoading = false;
  }

  // ---------------- ADD FRIEND ----------------
  Future<void> addFriend() async {
    if (isLoading || isFriend) return;
    isLoading = true;

    isFriend = true;
    isFollowing = false;
    notifyListeners();

    await _service.addFriend(
      userId: _currentUserId,
      targetId: _targetUserId,
    );

    await refresh();
    isLoading = false;
  }

  // ---------------- UNFRIEND ----------------
  Future<void> unfriend() async {
    if (isLoading || !isFriend) return;
    isLoading = true;

    isFriend = false;
    notifyListeners();

    await _service.unfriendUser(
      userId: _currentUserId,
      targetId: _targetUserId,
    );

    await refresh();
    isLoading = false;
  }

  // ---------------- REFRESH ----------------
  Future<void> refresh() async {
    social = await _service.fetchSocialData(_targetUserId);
    notifyListeners();
  }
}
