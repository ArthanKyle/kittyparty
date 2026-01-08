import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:kittyparty/core/global_widgets/dialogs/dialog_info.dart';
import 'package:kittyparty/features/livestream/widgets/user_profile_sheet.dart';
import 'package:zego_uikit_prebuilt_live_audio_room/zego_uikit_prebuilt_live_audio_room.dart';
import '../../../core/config/zego_config.dart';
import '../../../core/constants/colors.dart';
import '../viewmodel/live_audio_room_viewmodel.dart';
import 'gift_modal.dart';
import 'user_avatar.dart';
import 'gift_animation_overlay.dart';

class ZegoRoomWidget extends StatefulWidget {
  final String roomId;
  final String hostId;
  final String roomName;
  final String userIdentification;
  final String? userName;
  final Map<String, Uint8List?> profileCache;
  final LiveAudioRoomViewmodel viewModel;
  final Future<ImageProvider?> Function(String) fetchProfilePicture;


  const ZegoRoomWidget({
    super.key,
    required this.roomId,
    required this.hostId,
    required this.roomName,
    required this.userIdentification,
    this.userName,
    required this.profileCache,
    required this.viewModel,
    required this.fetchProfilePicture,
  });

  @override
  State<ZegoRoomWidget> createState() => _ZegoRoomWidgetState();
}

class _ZegoRoomWidgetState extends State<ZegoRoomWidget> {
  late String _roomName;
  String? _selectedUserId;
  String? _selectedUserName;
  Uint8List? _selectedAvatarBytes;

  String compact(int v) => v.toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
  );


  @override
  void initState() {
    super.initState();
    _roomName = widget.roomName;
    widget.viewModel.initContext(context);
  }

  Future<void> _editRoomName(BuildContext context) async {
    final controller = TextEditingController(text: _roomName);

    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Edit Room Name",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: "New Room Name",
            labelStyle: TextStyle(fontSize: 12),
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: AppColors.accentBlack)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );


    if (newName != null && newName.isNotEmpty && newName != _roomName) {
      final success = await widget.viewModel.roomService.updateRoom(
        widget.roomId,
        {"RoomName": newName},
      );

      if (success != null) {
        setState(() => _roomName = newName);

        DialogInfo(
          headerText: "Room Name Updated",
          subText: "Your room name has been changed to \"$newName\".",
          confirmText: "OK",
          onConfirm: () => Navigator.of(context, rootNavigator: true).pop(),
          onCancel: () => Navigator.of(context, rootNavigator: true).pop(),
        ).build(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to update room name."),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isHost = widget.userIdentification == widget.hostId;

    final s = widget.viewModel.incomeSummary;

    // ✅ then read fields from s
    final today = s?.contributionTodayCoins ?? 0;
    final tierPaid = s?.dailyRewardTierPaid ?? 0;

    const tiers = [100000, 200000, 300000, 400000, 500000, 800000, 1000000, 2000000];
    int? nextTier() {
      for (final t in tiers) {
        if (t > tierPaid) return t;
      }
      return null;
    }

    final next = nextTier();

    final config = (isHost
        ? ZegoUIKitPrebuiltLiveAudioRoomConfig.host()
        : ZegoUIKitPrebuiltLiveAudioRoomConfig.audience())
      ..seat.hostIndexes = [0]
      ..seat.layout.rowConfigs = [
        ZegoLiveAudioRoomLayoutRowConfig(
          count: 4,
          alignment: ZegoLiveAudioRoomLayoutAlignment.center,
        ),
        for (int i = 0; i < 4; i++)
          ZegoLiveAudioRoomLayoutRowConfig(
            count: 4,
            alignment: ZegoLiveAudioRoomLayoutAlignment.center,
          ),
      ]
      ..seat.avatarBuilder = (ctx, size, user, extra) {
        final targetId = user?.id ?? '';
        final targetName = user?.name ?? targetId;

        final avatar = UserAvatar(
          userId: targetId,
          size: size.width,
          profileCache: widget.viewModel.profileCache,
          fetchProfilePicture: widget.viewModel.fetchProfilePicture,
        );

        if (targetId.isEmpty) return avatar;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onLongPress: () {
            debugPrint('🟢 LONG PRESS → $targetId');

            setState(() {
              _selectedUserId = targetId;
              _selectedUserName = targetName;
              _selectedAvatarBytes =
              widget.viewModel.profileCache[targetId];
            });
          },
          child: avatar,
        );
      }
      ..topMenuBar = ZegoLiveAudioRoomTopMenuBarConfig(
        buttons: [],
      );


    final giftButton = ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        backgroundColor: Colors.pinkAccent,
        padding: const EdgeInsets.all(12),
      ),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          useRootNavigator: true,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => GiftModal(
            viewModel: widget.viewModel,
            roomId: widget.roomId,
            receiverId: widget.hostId,
            senderId: widget.userIdentification,
          ),
        );
      },
      child: const Icon(Icons.card_giftcard, color: Colors.white),
    );

    if (isHost) {
      config.bottomMenuBar.hostExtendButtons = [giftButton];
    } else {
      config.bottomMenuBar.audienceExtendButtons = [giftButton];
    }

    return Stack(
      children: [
        ZegoUIKitPrebuiltLiveAudioRoom(
          appID: ZegoConfig.appID,
          appSign: ZegoConfig.appSign,
          userID: widget.userIdentification,
          userName: widget.userName ?? widget.userIdentification,
          roomID: widget.roomId,
          config: config,
        ),

        Positioned(
          top: 70,
          left: 20,
          right: 80,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _roomName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    shadows: [
                      Shadow(
                        blurRadius: 4,
                        color: Colors.black54,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // ✅ income badge (host only)
              if (isHost)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.65),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Today: ${compact(today)} coins",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Tier Paid: ${compact(tierPaid)}",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

              if (isHost)
                GestureDetector(
                  onTap: () => _editRoomName(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.edit, color: Colors.white, size: 18),
                  ),
                ),
            ],
          ),
        ),

        Positioned(
          right: 20,
          bottom: 200,
          child: FloatingActionButton.extended(
            onPressed: () => widget.viewModel.showGameListModal(context, widget.roomId),
            label: const Text('Games'),
            icon: const Icon(Icons.videogame_asset),
            backgroundColor: Colors.deepPurpleAccent,
          ),
        ),

        Positioned(
          top: 60,
          right: 20,
          child: GestureDetector(
            onTap: () async {
              final shouldExit = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(isHost ? 'End Room?' : 'Leave Room?'),
                  content: Text(
                    isHost
                        ? 'Are you sure you want to end this room for everyone?'
                        : 'Are you sure you want to leave this room?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: Text(
                        isHost ? 'End' : 'Leave',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );

              if (shouldExit == true) {
                final ok = isHost
                    ? await widget.viewModel.roomService.endRoom(widget.roomId, widget.hostId)
                    : await widget.viewModel.roomService.leaveRoom(widget.roomId, widget.userIdentification);

                if (ok) {
                  Navigator.of(context, rootNavigator: true).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isHost ? 'Failed to end room.' : 'Failed to leave room.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.8),
              ),
              child: const Icon(Icons.power_settings_new, color: Colors.white, size: 28),
            ),
          ),
        ),
        if (_selectedUserId != null)
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
              }, // absorb taps
              child: Builder(
                builder: (context) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_selectedUserId == null) return;

                    UserFrameProfileSheet.show(
                      context,
                      userId: _selectedUserId!,
                      displayName: _selectedUserName ?? _selectedUserId!,
                      avatarBytes: _selectedAvatarBytes,
                      badges: const [
                        _MiniBadge(icon: Icons.shield, text: '1', bg: Color(0xFF18B26B)),
                        _MiniBadge(icon: Icons.favorite, text: '1', bg: Color(0xFF34C6C6)),
                      ],
                    );

                    setState(() {
                      _selectedUserId = null;
                      _selectedUserName = null;
                      _selectedAvatarBytes = null;
                    });
                  });
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),

        GiftAnimationOverlay(vm: widget.viewModel),
      ],
    );
  }
}

class _MiniBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color bg;

  const _MiniBadge({
    required this.icon,
    required this.text,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
