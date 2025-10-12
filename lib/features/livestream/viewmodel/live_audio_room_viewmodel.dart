import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zego_uikit/zego_uikit.dart';
import '../../../core/services/api/userProfile_service.dart';
import '../../../core/utils/user_provider.dart';
import '../../../core/services/api/room_service.dart';
import '../../landing/model/userProfile.dart';
import '../widgets/game_modal.dart';

class LiveAudioRoomViewmodel extends ChangeNotifier {
  final UserProvider userProvider;
  final UserProfileService profileService;
  final RoomService roomService;

  bool hasPermission = false;
  bool permissionChecked = false;

  String? userIdentification;
  String? userName;
  UserProfile? userProfile;

  Uint8List? currentUserAvatar;
  final Map<String, Uint8List?> profileCache = {};

  bool _disposed = false;

  LiveAudioRoomViewmodel({
    required this.userProvider,
    required this.profileService,
    required this.roomService,
  });

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void safeNotify() {
    if (!_disposed) notifyListeners();
  }

  // ================================================================
  // ✅ INITIALIZATION
  // ================================================================
  Future<void> init(String roomId) async {
    await _requestPermission();
    await _initializeCurrentUser(roomId);
    _subscribeToUserEvents();
  }

  Future<void> _requestPermission() async {
    final status = await Permission.microphone.request();
    hasPermission = status.isGranted;
    permissionChecked = true;
    safeNotify();
  }

  // ================================================================
  // ✅ INITIALIZE CURRENT USER + FETCH OWN AVATAR
  // ================================================================
  Future<void> _initializeCurrentUser(String roomId) async {
    final currentUser = userProvider.currentUser;
    if (currentUser == null) return;

    userIdentification = currentUser.userIdentification;
    userName = currentUser.username;

    // Fetch the current user profile (like ProfileViewModel)
    final result = await profileService.getProfileByUserId(currentUser.id);
    if (result != null) {
      userProfile = result;
      if (userProfile!.profilePicture != null &&
          userProfile!.profilePicture!.isNotEmpty) {
        currentUserAvatar =
        await profileService.fetchProfilePicture(currentUser.id);
        profileCache[userIdentification!] = currentUserAvatar;
      }
    }

    // Join the live room after loading profile info
    await roomService.joinRoom(roomId, userIdentification!);
    safeNotify();
  }

  // ================================================================
  // ✅ FETCH PROFILE PICTURE (CACHED)
  // ================================================================
  Future<ImageProvider?> fetchProfilePicture(String userId) async {
    // 1️⃣ Return from cache if available
    final cachedBytes = profileCache[userId];
    if (cachedBytes != null && cachedBytes.isNotEmpty) {
      return MemoryImage(cachedBytes);
    }

    // 2️⃣ Fetch from API
    final fetchedBytes = await profileService.fetchProfilePicture(userId);
    if (fetchedBytes != null && fetchedBytes.isNotEmpty) {
      profileCache[userId] = fetchedBytes;
      safeNotify();
      return MemoryImage(fetchedBytes);
    }

    // 3️⃣ If no image found, return null (fallback to default avatar)
    return null;
  }

  // ================================================================
  // ✅ PRELOAD MULTIPLE USER AVATARS
  // ================================================================
  Future<void> preloadAvatars(List<String> userIds) async {
    for (final userId in userIds) {
      if (!profileCache.containsKey(userId)) {
        final image = await fetchProfilePicture(userId);
        if (image is MemoryImage) {
          profileCache[userId] = (image as MemoryImage).bytes;
        }
      }
    }
  }

  // ================================================================
  // ✅ SUBSCRIBE TO USER JOIN/LEAVE EVENTS
  // ================================================================
  void _subscribeToUserEvents() {
    ZegoUIKit().getUserJoinStream().listen((users) {
      for (final user in users) {
        _preloadUserAvatar(user.id);
      }
    });

    ZegoUIKit().getUserLeaveStream().listen((users) {
      // Optionally remove from cache or keep
    });
  }

  Future<void> _preloadUserAvatar(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (!profileCache.containsKey(userId)) {
      final bytes = await profileService.fetchProfilePicture(userId);
      if (bytes != null && bytes.isNotEmpty) {
        profileCache[userId] = bytes;
        safeNotify();
      }
    }
  }
// ================================================================
// GAME
// ================================================================
  Future<void> showGameListModal(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black.withOpacity(0.9),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const GameListModal(),
    );
  }


}
