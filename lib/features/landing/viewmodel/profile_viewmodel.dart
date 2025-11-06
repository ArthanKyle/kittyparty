import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/global_widgets/dialogs/dialog_loading.dart';
import '../../../core/utils/user_provider.dart';
import '../model/userProfile.dart';
import '../../../core/services/api/userProfile_service.dart';
import '../../../core/services/api/social_service.dart';
import '../../landing/model/socials.dart';

class ProfileViewModel extends ChangeNotifier {
  final UserProfileService _profileService = UserProfileService();
  final SocialService _socialService = SocialService();

  UserProfile? userProfile;
  Uint8List? profilePictureBytes;
  Social? userSocial;
  bool isLoading = true;
  String? error;

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void safeNotify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> loadProfile(BuildContext context) async {
    isLoading = true;
    safeNotify();

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentUser = userProvider.currentUser;

      if (currentUser == null || currentUser.userIdentification.isEmpty) {
        error = "No logged in user";
        isLoading = false;
        safeNotify();
        return;
      }

      // Fetch profile data
      final result = await _profileService.getProfileByUserId(currentUser.userIdentification);

      if (_disposed) return;

      if (result != null) {
        userProfile = result;

        if (userProfile!.userIdentification.isEmpty) {
          userProfile!.userIdentification = currentUser.userIdentification;
        }

        // Fetch profile picture if exists
        if (userProfile!.profilePicture != null &&
            userProfile!.profilePicture!.isNotEmpty) {
          profilePictureBytes = await _profileService
              .fetchProfilePicture(currentUser.userIdentification);
        }
      } else {
        userProfile = UserProfile(
          userIdentification: currentUser.userIdentification,
          bio: "",
          profilePicture: null,
        );
      }

      // Fetch socials (followings, fans, etc.)
      final social = await _socialService
          .fetchSocialData(int.tryParse(currentUser.userIdentification) ?? 0);

      if (social != null) {
        userSocial = social;
      }
    } catch (e) {
      error = "Failed to load profile: $e";
    } finally {
      isLoading = false;
      safeNotify();
    }
  }

  Future<void> changeProfilePicture(BuildContext context, File imageFile) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.currentUser;
    if (currentUser == null) return;

    DialogLoading(subtext: "Uploading profile picture...").build(context);

    try {
      Navigator.of(context, rootNavigator: true).pop();
      final updated = await _profileService.uploadProfilePicture(
        currentUser.userIdentification,
        imageFile,
      );
      if (_disposed) return;

      if (updated != null) {
        userProfile = updated;
        profilePictureBytes = await _profileService
            .fetchProfilePicture(currentUser.userIdentification);

        if (userProfile!.userIdentification.isEmpty) {
          userProfile!.userIdentification = currentUser.userIdentification;
        }

        safeNotify();
      }
    } catch (e) {
      debugPrint("❌ Failed to update picture: $e");
    }
  }
}
