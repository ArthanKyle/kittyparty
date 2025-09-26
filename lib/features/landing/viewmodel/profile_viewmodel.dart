import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/global_widgets/dialogs/dialog_info.dart';
import '../../../core/global_widgets/dialogs/dialog_loading.dart';
import '../../../core/utils/user_provider.dart';
import '../model/userProfile.dart';
import '../../../core/services/api/userProfile_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final UserProfileService _service = UserProfileService();

  UserProfile? userProfile;
  Uint8List? profilePictureBytes;
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
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentUser = userProvider.currentUser;
      if (currentUser == null || currentUser.id.isEmpty) {
        error = "No logged in user";
        isLoading = false;
        safeNotify();
        return;
      }

      final result = await _service.getProfileByUserId(currentUser.id);
      if (_disposed) return; // prevent work after dispose

      if (result != null) {
        userProfile = result;
        if (userProfile!.profilePicture != null && userProfile!.profilePicture!.isNotEmpty) {
          profilePictureBytes = await _service.fetchProfilePicture(currentUser.id);
        }
      } else {
        userProfile = UserProfile(userId: currentUser.id, bio: "", profilePicture: null);
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
      final updated = await _service.uploadProfilePicture(currentUser.id, imageFile);
      if (_disposed) return;

      if (updated != null) {
        userProfile = updated;
        profilePictureBytes = await _service.fetchProfilePicture(currentUser.id);
        safeNotify();
      }
    } catch (e) {
      debugPrint("❌ Failed to update picture: $e");
    }
  }
}
