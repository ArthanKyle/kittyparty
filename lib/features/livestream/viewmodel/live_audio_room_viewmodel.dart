import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

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
  bool _disposed = false;

  String? userIdentification;
  String? userName;
  UserProfile? userProfile;

  Uint8List? currentUserAvatar;
  final Map<String, Uint8List?> profileCache = {};

  BuildContext? globalContext;

  StreamSubscription<List<ZegoUIKitUser>>? _zegoJoinSubscription;

  final StreamController<String> _giftController =
  StreamController<String>.broadcast();
  Stream<String> get giftStream => _giftController.stream;

  RoomIncomeSummary? incomeSummary;
  String? _hostId;

  bool get isHost =>
      userIdentification != null &&
          _hostId != null &&
          userIdentification == _hostId;

  IO.Socket? _socket;

  void initContext(BuildContext context) {
    globalContext = context;
  }

  int _asInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  Future<void> init(String roomId, {required String hostId}) async {
    _hostId = hostId;

    await _requestPermission();
    if (!hasPermission) {
      _safeNotify();
      return;
    }

    await _loadCurrentUser();
    await _joinBackendRoom(roomId);

    _subscribeToZegoUserEvents();
    _initRoomSocket(roomId);

    // initial fetch
    if (isHost) {
      incomeSummary = await roomIncomeService.getSummary(roomId);
    }

    _safeNotify();
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
    if (profile == null) return;

    userProfile = profile;

    if (profile.profilePicture != null && profile.profilePicture!.isNotEmpty) {
      currentUserAvatar =
      await profileService.fetchProfilePicture(currentUser.id);
      if (currentUserAvatar != null) {
        profileCache[userIdentification!] = currentUserAvatar;
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
      _safeNotify();
    }
  }

  Future<ImageProvider?> fetchProfilePicture(String userId) async {
    final cached = profileCache[userId];
    if (cached != null && cached.isNotEmpty) return MemoryImage(cached);

    final bytes = await profileService.fetchProfilePicture(userId);
    if (bytes != null && bytes.isNotEmpty) {
      profileCache[userId] = bytes;
      _safeNotify();
      return MemoryImage(bytes);
    }
    return null;
  }

  // ✅ Socket connects to host (NO /api)
  void _initRoomSocket(String roomId) {
    _socket = IO.io(
      roomIncomeService.socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .build(),
    );

    _socket!.onConnect((_) {
      _socket!.emit("joinRoom", roomId);
    });

    _socket!.on("room_income_update", (data) {
      if (data is! Map) return;

      incomeSummary = RoomIncomeSummary(
        contributionTodayCoins: _asInt(data["contributionTodayCoins"]),
        contributionTotalCoins: _asInt(data["contributionTotalCoins"]),
        dailyRewardTierPaid: _asInt(data["dailyRewardTierPaid"]),
        lastResetAt: null,
      );
      _safeNotify();
    });
  }

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
    final txId = (result["txId"] ?? "").toString();

    final totalCoinsSpent = _asInt(result["totalCoinsSpent"]);
    final coinsWon = _asInt(result["coinsWon"]);

    // 1) gift spend -> income
    if (totalCoinsSpent > 0) {
      final ok = await roomIncomeService.recordIncome(
        roomId: roomId,
        eventType: "gift_sent",
        amountCoins: totalCoinsSpent,
        senderId: senderId,
        receiverId: receiverId,
        externalId: txId.isEmpty ? null : txId,
        meta: {
          "giftType": giftType,
          "giftCount": giftCount,
          "giftName": giftName,
          "txId": txId,
        },
      );
      debugPrint("🟣 recordIncome gift_sent ok=$ok amount=$totalCoinsSpent txId=$txId");
    }

    // 2) coinback -> income too
    if (coinsWon > 0) {
      final ok2 = await roomIncomeService.recordIncome(
        roomId: roomId,
        eventType: "lucky_coinback",
        amountCoins: coinsWon,
        senderId: senderId,
        receiverId: senderId,
        externalId: txId.isEmpty ? null : "coinback:$txId",
        meta: {
          "source": "lucky_gift",
          "giftType": giftType,
          "giftCount": giftCount,
          "giftName": giftName,
          "txId": txId,
        },
      );
      debugPrint("🟣 recordIncome lucky_coinback ok=$ok2 amount=$coinsWon txId=$txId");
    }

    // quick verify
    final s = await roomIncomeService.getSummary(roomId);
    debugPrint("🟣 summary today=${s?.contributionTodayCoins} total=${s?.contributionTotalCoins}");

    if (giftName.isNotEmpty) _giftController.add(giftName);

    if (coinsWon > 0 && globalContext != null) {
      ScaffoldMessenger.of(globalContext!).showSnackBar(
        SnackBar(
          content: Text("🎉 Lucky Win! +$coinsWon coins"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
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
    _socket?.emit("leaveRoom", null);
    _socket?.disconnect();
    _socket?.dispose();

    _giftController.close();
    _zegoJoinSubscription?.cancel();
    _disposed = true;
    super.dispose();
  }
}
