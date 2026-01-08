// lib/features/livestream/viewmodel/live_audio_room_viewmodel.dart
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zego_uikit/zego_uikit.dart';

import '../../../core/services/api/gift_service.dart';
import '../../../core/services/api/room_income_service.dart';
import '../../../core/services/api/userProfile_service.dart';
import '../../../core/services/api/room_service.dart';
import '../../../core/utils/user_provider.dart';
import '../../landing/model/userProfile.dart';
import '../widgets/game_modal.dart';

class LiveAudioRoomViewmodel extends ChangeNotifier {
  final UserProvider userProvider;
  final UserProfileService profileService;
  final RoomService roomService;

  final GiftService giftService = GiftService();
  final RoomIncomeService roomIncomeService = RoomIncomeService();

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

  // ===== Room Income (Host UI) =====
  RoomIncomeSummary? incomeSummary;
  Timer? _incomeTimer;
  String? _hostId;

  bool get isHost =>
      userIdentification != null && _hostId != null && userIdentification == _hostId;

  void initContext(BuildContext context) {
    globalContext = context;
  }

  void safeNotify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> init(String roomId, {required String hostId}) async {
    _hostId = hostId;

    await _requestPermission();
    if (!hasPermission) {
      safeNotify();
      return;
    }

    await _loadCurrentUser();
    await _joinBackendRoom(roomId);
    _subscribeToZegoUserEvents();

    _startIncomePollingIfHost(roomId);

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

      if (profile.profilePicture != null && profile.profilePicture!.isNotEmpty) {
        currentUserAvatar = await profileService.fetchProfilePicture(currentUser.id);
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
    _zegoJoinSubscription = ZegoUIKit().getUserJoinStream().listen((users) async {
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
    if (cached != null && cached.isNotEmpty) return MemoryImage(cached);

    final bytes = await profileService.fetchProfilePicture(userId);
    if (bytes != null && bytes.isNotEmpty) {
      profileCache[userId] = bytes;
      safeNotify();
      return MemoryImage(bytes);
    }

    return null;
  }

  // ===== Income Polling =====
  void _startIncomePollingIfHost(String roomId) {
    _incomeTimer?.cancel();

    if (!isHost) return;

    _fetchIncomeSummary(roomId);

    _incomeTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _fetchIncomeSummary(roomId);
    });
  }

  Future<void> _fetchIncomeSummary(String roomId) async {
    final summary = await roomIncomeService.getSummary(roomId);
    if (summary == null) return;
    incomeSummary = summary;
    safeNotify();
  }

  // ===== Gift Send + Room Income Record =====
  Future<void> sendGift({
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

    final giftName = (result["giftName"] ?? "").toString();
    final coinsWon = (result["coinsWon"] ?? 0) as int;

    // REQUIRED: backend must return this (total coins spent for the gift)
    final totalCoinsSpent = (result["totalCoinsSpent"] ?? 0) as int;

    if (totalCoinsSpent > 0) {
      await roomIncomeService.recordIncome(
        roomId: roomId,
        eventType: "gift_sent",
        amountCoins: totalCoinsSpent,
        senderId: senderId,
        receiverId: receiverId,
        meta: {
          "giftType": giftType,
          "giftCount": giftCount,
          "giftName": result["giftName"] ?? "",
          "giftID": result["giftID"] ?? giftType,
          "txId": result["txId"] ?? "",
        },
      );

      if (isHost) {
        await _fetchIncomeSummary(roomId);
      }
    }

    // 3) Trigger gift animation
    if (giftName.isNotEmpty) _giftController.add(giftName);

    // 4) Lucky popup
    if (coinsWon > 0 && globalContext != null) {
      ScaffoldMessenger.of(globalContext!).showSnackBar(
        SnackBar(
          content: Text("🎉 Lucky Win! +$coinsWon coins"),
          backgroundColor: Colors.green,
        ),
      );

      // OPTIONAL: if you want coinback to count as contribution too
      // await roomIncomeService.recordIncome(
      //   roomId: roomId,
      //   eventType: "lucky_coinback",
      //   amountCoins: coinsWon,
      //   senderId: senderId,
      //   receiverId: senderId,
      //   meta: {"source": "lucky_gift"},
      // );
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

  @override
  void dispose() {
    _incomeTimer?.cancel();
    _giftController.close();
    _zegoJoinSubscription?.cancel();
    _disposed = true;
    super.dispose();
  }
}
