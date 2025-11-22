import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/global_widgets/dialogs/dialog_loading.dart';
import '../../../core/services/api/userProfile_service.dart';
import '../../../core/services/api/social_service.dart';
import '../../../core/utils/user_provider.dart';
import '../../landing/model/socials.dart';
import '../model/userProfile.dart';

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

  /// Load profile and social data (only once per call)
  Future<void> loadProfile(BuildContext context) async {
    if (_disposed) return;
    isLoading = true;
    safeNotify();

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentUser = userProvider.currentUser;
      if (currentUser == null) {
        error = "No logged in user";
        isLoading = false;
        safeNotify();
        return;
      }

      // Fetch profile
      final profile = await _profileService.getProfileByUserId(currentUser.userIdentification);
      if (_disposed) return;
      userProfile = profile ??
          UserProfile(
            userIdentification: currentUser.userIdentification,
            bio: "",
            profilePicture: null,
          );

      if (userProfile!.profilePicture != null && userProfile!.profilePicture!.isNotEmpty) {
        profilePictureBytes =
        await _profileService.fetchProfilePicture(currentUser.userIdentification);
      }

      // Fetch social data once
      await fetchSocialData(currentUser.userIdentification);

    } catch (e) {
      error = "Failed to load profile: $e";
    } finally {
      isLoading = false;
      safeNotify();
    }
  }

  /// Fetch social data manually
  Future<void> fetchSocialData(String userId) async {
    try {
      final social = await _socialService.fetchSocialData(int.tryParse(userId) ?? 0);
      if (_disposed) return;
      if (social != null) {
        userSocial = social;
        safeNotify();
      }
    } catch (_) {
      // ignore errors silently
    }
  }

  /// Upload new profile picture
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
        profilePictureBytes =
        await _profileService.fetchProfilePicture(currentUser.userIdentification);
        safeNotify();
      }
    } catch (e) {
      debugPrint("❌ Failed to update picture: $e");
    }
  }
}