import 'package:flutter/cupertino.dart';

import '../../../core/services/api/social_service.dart';
import '../model/socials.dart';

class SocialViewModel extends ChangeNotifier {
  final _service = SocialService();

  Social? social;
  bool isFollowing = false;

  Future<void> load(String userId) async {
    social = await _service.fetchSocialData(userId);
    notifyListeners();
  }

  Future<void> toggleFollow() async {
    // hook into follow/unfollow later with currentUserId
  }
}
