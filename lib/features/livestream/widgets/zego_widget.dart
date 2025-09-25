import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_live_audio_room/zego_uikit_prebuilt_live_audio_room.dart';
import '../../../core/config/zego_config.dart';
import 'user_avatar.dart';
import 'package:zego_uikit/zego_uikit.dart';

class ZegoRoomWidget extends StatelessWidget {
  final String roomId;
  final String hostId;
  final String roomName;
  final String userIdentification;
  final String? fullName;
  final Map<String, Uint8List?> profileCache;

  const ZegoRoomWidget({
    super.key,
    required this.roomId,
    required this.hostId,
    required this.roomName,
    required this.userIdentification,
    this.fullName,
    required this.profileCache,
  });

  @override
  Widget build(BuildContext context) {
    final isHost = userIdentification == hostId;

    return ZegoUIKitPrebuiltLiveAudioRoom(
      appID: ZegoConfig.appID,
      appSign: ZegoConfig.appSign,
      userID: userIdentification,
      userName: fullName ?? userIdentification,
      roomID: roomId,
      config: (isHost
          ? (ZegoUIKitPrebuiltLiveAudioRoomConfig.host()
        ..seat.takeIndexWhenJoining = 0)
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
        ..seat.avatarBuilder =
            (context, size, ZegoUIKitUser? user, extraInfo) {
          return UserAvatar(
            userId: user?.id ?? "",
            size: MediaQuery.of(context).size.width * 0.12,
            profileCache: profileCache,
            fetchProfilePicture: (id) async {
              final bytes = profileCache[id];
              if (bytes == null) return null;
              return MemoryImage(bytes);
            },
          );
        },
    );
  }
}
