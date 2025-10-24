import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_live_audio_room/zego_uikit_prebuilt_live_audio_room.dart';
import '../../../core/config/zego_config.dart';
import '../../../core/constants/colors.dart';
import '../viewmodel/live_audio_room_viewmodel.dart';
import 'user_avatar.dart';
import 'package:zego_uikit/zego_uikit.dart';
import '../../../core/services/api/room_service.dart';

class ZegoRoomWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final isHost = userIdentification == hostId;

    // ✅ Build config & remove built-in leave/power icon
    final config = (isHost
        ? (ZegoUIKitPrebuiltLiveAudioRoomConfig.host()
      ..seat.takeIndexWhenJoining = 0)
        : ZegoUIKitPrebuiltLiveAudioRoomConfig.audience())
      ..seat.hostIndexes = [0]
      ..seat.layout.rowConfigs = [
        ZegoLiveAudioRoomLayoutRowConfig(
            count: 4, alignment: ZegoLiveAudioRoomLayoutAlignment.center),
        for (int i = 0; i < 4; i++)
          ZegoLiveAudioRoomLayoutRowConfig(
              count: 4, alignment: ZegoLiveAudioRoomLayoutAlignment.center),
      ]
      ..seat.avatarBuilder = (context, size, zegoUser, extraInfo) {
        final vm = viewModel;
        return UserAvatar(
          userId: zegoUser?.id ?? "",
          size: size.width,
          profileCache: vm.profileCache,
          fetchProfilePicture: vm.fetchProfilePicture,
        );
      }
    // 🚫 This removes the built-in top-right leave/power icon entirely
      ..topMenuBar = ZegoLiveAudioRoomTopMenuBarConfig(
        buttons: [], // removes the default leave button
      );

    return Stack(
      children: [
        /// 🎤 Live Audio Room
        ZegoUIKitPrebuiltLiveAudioRoom(
          appID: ZegoConfig.appID,
          appSign: ZegoConfig.appSign,
          userID: userIdentification,
          userName: userName ?? userIdentification,
          roomID: roomId,
          config: config,
        ),

        /// 🟣 Game Button (Bottom Right)
        Positioned(
          right: 20,
          bottom: 70,
          child: FloatingActionButton.extended(
            onPressed: () => viewModel.showGameListModal(context),
            label: const Text('Games'),
            icon: const Icon(Icons.videogame_asset),
            backgroundColor: Colors.deepPurpleAccent,
          ),
        ),

        /// 🔌 Custom End/Leave Room Button (Replaces built-in one)
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
                      child: const Text('Cancel',style: TextStyle(color: AppColors.accentBlack),),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                      ),
                      child: Text(isHost ? 'End' : 'Leave',style: TextStyle(color: AppColors.accentBlack),),
                    ),
                  ],
                ),
              );

              if (shouldExit == true) {
                final roomService = viewModel.roomService;
                final success = isHost
                    ? await roomService.endRoom(roomId, hostId)
                    : await roomService.leaveRoom(roomId, userIdentification);

                if (success) {
                  Navigator.of(context).pop(); // Close room
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isHost
                            ? 'Failed to end the room.'
                            : 'Failed to leave the room.',
                      ),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              }
            },
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade800.withOpacity(0.9),
              ),
              padding: const EdgeInsets.all(10),
              child: const Icon(
                Icons.power_settings_new,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
