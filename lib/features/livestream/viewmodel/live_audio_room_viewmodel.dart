import 'dart:async';
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

class LiveAudioRoomViewmodel extends ChangeNotifier {
  final UserProvider userProvider;
  final UserProfileService profileService;
  final RoomService roomService;
  final GiftService giftService = GiftService();

  LiveAudioRoomViewmodel({
    required this.userProvider,
    required this.profileService,
    required this.roomService,
  });

  bool hasPermission = false;
  bool permissionChecked = false;

  String? userIdentification;
  String? userName;
  UserProfile? userProfile;

  Uint8List? currentUserAvatar;
  final Map<String, Uint8List?> profileCache = {};

  BuildContext? globalContext;
  bool _disposed = false;

  StreamSubscription<List<ZegoUIKitUser>>? _zegoJoinSubscription;

  final StreamController<String> _giftController =
  StreamController<String>.broadcast();
  Stream<String> get giftStream => _giftController.stream;

  void initContext(BuildContext context) {
    globalContext = context;
  }

  @override
  void dispose() {
    _giftController.close();
    _zegoJoinSubscription?.cancel();
    _disposed = true;
    super.dispose();
  }

  void safeNotify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> init(String roomId) async {
    await _requestPermission();

    if (!hasPermission) {
      safeNotify();
      return;
    }

    await _loadCurrentUser();
    await _joinBackendRoom(roomId);
    _subscribeToZegoUserEvents();
    safeNotify();
  }

  Future<void> _requestPermission() async {
    final status = await Permission.microphone.request();
    hasPermission = status.isGranted;
    permissionChecked = true;
  }

  Future<void> _loadCurrentUser() async {
    final currentUser = userProvider.currentUser;
    if (currentUser == null) return;

    userIdentification = currentUser.userIdentification;
    userName = currentUser.username;

    final profile = await profileService.getProfileByUserIdentification(
      currentUser.userIdentification,
    );

    if (profile != null) {
      userProfile = profile;

      if (profile.profilePicture != null &&
          profile.profilePicture!.isNotEmpty) {
        currentUserAvatar =
        await profileService.fetchProfilePicture(currentUser.id);

        if (currentUserAvatar != null) {
          profileCache[userIdentification!] = currentUserAvatar;
        }
      }
    }
  }

  Future<void> _joinBackendRoom(String roomId) async {
    if (userIdentification == null) return;
    await roomService.joinRoom(roomId, userIdentification!);
  }

  void _subscribeToZegoUserEvents() {
    _zegoJoinSubscription =
        ZegoUIKit().getUserJoinStream().listen((users) async {
          for (final user in users) {
            await _preloadAvatar(user.id);
          }
        });
  }

  Future<void> _preloadAvatar(String userId) async {
    if (profileCache.containsKey(userId)) return;

    final bytes = await profileService.fetchProfilePicture(userId);
    if (bytes != null && bytes.isNotEmpty) {
      profileCache[userId] = bytes;
      safeNotify();
    }
  }

  Future<ImageProvider?> fetchProfilePicture(String userId) async {
    final cached = profileCache[userId];
    if (cached != null && cached.isNotEmpty) {
      return MemoryImage(cached);
    }

    final bytes = await profileService.fetchProfilePicture(userId);
    if (bytes != null && bytes.isNotEmpty) {
      profileCache[userId] = bytes;
      safeNotify();
      return MemoryImage(bytes);
    }

    return null;
  }

  void sendGift({
    required String roomId,
    required String senderId,
    required String receiverId,
    required String giftType,
    required int giftCount,
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

    if (result["success"] != true) return;

    final giftName = result["giftName"];
    final coinsWon = result["coinsWon"] ?? 0;

    // animation trigger
    _giftController.add(giftName);

    // OPTIONAL: lucky popup hook
    if (coinsWon > 0 && globalContext != null) {
      ScaffoldMessenger.of(globalContext!).showSnackBar(
        SnackBar(
          content: Text("🎉 Lucky Win! +$coinsWon coins"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }


  Future<void> showGameListModal(BuildContext context, String roomId) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black.withOpacity(0.9),
      builder: (_) => GameListModal(roomId: roomId),
    );
  }
}
