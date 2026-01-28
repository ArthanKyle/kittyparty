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

  Future<void> load({
    required String currentUserId,
    required String targetUserId,
  }) async {
    _currentUserId = currentUserId;
    _targetUserId = targetUserId;

    isLoading = true;
    notifyListeners();

    social = await _service.fetchSocialData(targetUserId);

    isFollowing = await _service.isFollowing(
      userId: currentUserId,
      targetId: targetUserId,
    );

    isFriend = await _service.isFriend(
      userId: currentUserId,
      targetId: targetUserId,
    );

    isLoading = false;
    notifyListeners();
  }

  Future<void> follow() async {
    if (isLoading) return;
    isLoading = true;
    notifyListeners();

    await _service.followUser(
      userId: _currentUserId,
      targetId: _targetUserId,
    );

    await load(
      currentUserId: _currentUserId,
      targetUserId: _targetUserId,
    );
  }

  Future<void> unfollow() async {
    if (isLoading) return;
    isLoading = true;
    notifyListeners();

    await _service.unfollowUser(
      userId: _currentUserId,
      targetId: _targetUserId,
    );

    await load(
      currentUserId: _currentUserId,
      targetUserId: _targetUserId,
    );
  }

  Future<void> addFriend() async {
    if (isLoading) return;
    isLoading = true;
    notifyListeners();

    await _service.addFriend(
      userId: _currentUserId,
      targetId: _targetUserId,
    );

    await load(
      currentUserId: _currentUserId,
      targetUserId: _targetUserId,
    );
  }

  Future<void> unfriend() async {
    if (isLoading) return;
    isLoading = true;
    notifyListeners();

    await _service.unfriendUser(
      userId: _currentUserId,
      targetId: _targetUserId,
    );

    await load(
      currentUserId: _currentUserId,
      targetUserId: _targetUserId,
    );
  }
}
