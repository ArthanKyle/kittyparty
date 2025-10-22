import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_live_audio_room/zego_uikit_prebuilt_live_audio_room.dart';
import '../../../core/config/zego_config.dart';
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

    return Stack(
      children: [
        ZegoUIKitPrebuiltLiveAudioRoom(
          appID: ZegoConfig.appID,
          appSign: ZegoConfig.appSign,
          userID: userIdentification,
          userName: userName ?? userIdentification,
          roomID: roomId,
          config: (isHost
              ? (ZegoUIKitPrebuiltLiveAudioRoomConfig.host()
            ..seat.takeIndexWhenJoining = 0)
              : ZegoUIKitPrebuiltLiveAudioRoomConfig.audience())
            ..seat.hostIndexes = [0]
            ..seat.layout.rowConfigs = [
              ZegoLiveAudioRoomLayoutRowConfig(
                  count: 4, alignment: ZegoLiveAudioRoomLayoutAlignment.center),
              for (int i = 0; i < 4; i++)
                ZegoLiveAudioRoomLayoutRowConfig(count: 4,
                    alignment: ZegoLiveAudioRoomLayoutAlignment.center),
            ]
            ..seat.avatarBuilder = (context, size, zegoUser, extraInfo) {
              final vm = viewModel;
              return UserAvatar(
                userId: zegoUser?.id ?? "",
                size: size.width,
                profileCache: vm.profileCache,
                fetchProfilePicture: vm.fetchProfilePicture,
              );
            },
        ),

        // 🎮 Game Button
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
      ],
    );
  }
}