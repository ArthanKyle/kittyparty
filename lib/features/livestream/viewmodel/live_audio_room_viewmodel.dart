import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/services/api/userProfile_service.dart';
import '../../../core/utils/user_provider.dart';


class LiveAudioRoomViewmodel extends ChangeNotifier {
  final UserProvider userProvider;
  final UserProfileService profileService;

  LiveAudioRoomViewmodel({
    required this.userProvider,
    required this.profileService,
  });

  bool hasPermission = false;
  bool permissionChecked = false;
  String? userIdentification;
  String? fullName;

  /// Stores profile pictures as bytes
  final Map<String, Uint8List?> profileCache = {};

  Future<void> init() async {
    await _requestPermission();
    await _initializeCurrentUser();
  }

  Future<void> _requestPermission() async {
    final status = await Permission.microphone.request();
    hasPermission = status.isGranted;
    permissionChecked = true;
    notifyListeners();
  }

  /// Load current user info and profile picture bytes
  Future<void> _initializeCurrentUser() async {
    final currentUser = userProvider.currentUser;
    if (currentUser != null) {
      userIdentification = currentUser.userIdentification;
      fullName = currentUser.fullName;

      // Fetch profile picture bytes using UserProfileService
      final bytes = await profileService.fetchProfilePicture(userIdentification!);
      profileCache[userIdentification!] = bytes;

      notifyListeners();
    }
  }

  /// Helper for Zego avatars
  Future<Uint8List?> fetchProfilePictureBytes(String userId) async {
    return profileCache[userId];
  }
}
