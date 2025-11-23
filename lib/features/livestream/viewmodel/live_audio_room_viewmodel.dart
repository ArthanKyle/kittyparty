import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zego_uikit/zego_uikit.dart';
import '../../../core/services/api/gift_service.dart';
import '../../../core/services/api/userProfile_service.dart';
import '../../../core/utils/user_provider.dart';
import '../../../core/services/api/room_service.dart';
import '../../landing/model/userProfile.dart';
import '../widgets/game_modal.dart';
import '../widgets/gift_svga_player.dart';

class LiveAudioRoomViewmodel extends ChangeNotifier {
  final UserProvider userProvider;
  final UserProfileService profileService;
  final RoomService roomService;
  final GiftService giftService = GiftService();

  bool hasPermission = false;
  bool permissionChecked = false;

  String? userIdentification;
  String? userName;
  UserProfile? userProfile;

  Uint8List? currentUserAvatar;
  final Map<String, Uint8List?> profileCache = {};

  BuildContext? globalContext;

  bool _disposed = false;

  LiveAudioRoomViewmodel({
    required this.userProvider,
    required this.profileService,
    required this.roomService,
  });

  void initContext(BuildContext context) {
    globalContext = context;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void safeNotify() {
    if (!_disposed) notifyListeners();
  }

  // ================================================================
  // INITIALIZATION
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

  Future<void> _initializeCurrentUser(String roomId) async {
    final currentUser = userProvider.currentUser;
    if (currentUser == null) return;

    userIdentification = currentUser.userIdentification;
    userName = currentUser.username;

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

    await roomService.joinRoom(roomId, userIdentification!);
    safeNotify();
  }

  // ================================================================
  // PROFILE PICTURE CACHING
  // ================================================================
  Future<ImageProvider?> fetchProfilePicture(String userId) async {
    final cachedBytes = profileCache[userId];
    if (cachedBytes != null && cachedBytes.isNotEmpty) {
      return MemoryImage(cachedBytes);
    }

    final fetchedBytes = await profileService.fetchProfilePicture(userId);
    if (fetchedBytes != null && fetchedBytes.isNotEmpty) {
      profileCache[userId] = fetchedBytes;
      safeNotify();
      return MemoryImage(fetchedBytes);
    }

    return null;
  }

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

  void _subscribeToUserEvents() {
    ZegoUIKit().getUserJoinStream().listen((users) {
      for (final user in users) {
        _preloadUserAvatar(user.id);
      }
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
  // SEND GIFT (FINAL)
  // ================================================================
  Future<void> sendGift({
    required String roomId,
    required String senderId,     // <-- add this
    required String receiverId,
    required String giftType,
    int giftCount = 1,
  }) async {
    final token = userProvider.token;
    if (token == null) return;

    final result = await giftService.sendGift(
      token: token,
      roomId: roomId,
      senderId: senderId,
      receiverId: receiverId,
      giftType: giftType,
      giftCount: giftCount,
    );

    if (!result["success"]) {
      print("Gift Error: ${result["message"]}");
      return;
    }

    // Play SVGA effect
    SvgaGiftQueue().add(
      globalContext!,
      "assets/image/gift/${result["giftName"]}.svga",
    );

    print("Gift sent: ${result["giftName"]}");
  }


  // ================================================================
  // GAME MODAL
  // ================================================================
  Future<void> showGameListModal(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black.withOpacity(0.9),
      builder: (_) => const GameListModal(),
    );
  }
}
