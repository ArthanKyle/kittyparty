import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:kittyparty/core/global_widgets/dialogs/dialog_info.dart';
import 'package:zego_uikit_prebuilt_live_audio_room/zego_uikit_prebuilt_live_audio_room.dart';
import '../../../core/config/zego_config.dart';
import '../../../core/constants/colors.dart';
import '../viewmodel/live_audio_room_viewmodel.dart';
import 'user_avatar.dart';
import 'package:zego_uikit/zego_uikit.dart';

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

  @override
  void initState() {
    super.initState();
    _roomName = widget.roomName;
  }

  Future<void> _editRoomName(BuildContext context) async {
    final TextEditingController controller = TextEditingController(text: _roomName);

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
      final success = await widget.viewModel.roomService
          .updateRoom(widget.roomId, {"RoomName": newName});

      if (success != null) {
        setState(() {
          _roomName = newName;
        });

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
        final vm = widget.viewModel;
        return UserAvatar(
          userId: zegoUser?.id ?? "",
          size: size.width,
          profileCache: vm.profileCache,
          fetchProfilePicture: vm.fetchProfilePicture,
        );
      }
      ..topMenuBar = ZegoLiveAudioRoomTopMenuBarConfig(buttons: []);

    return Stack(
      children: [
        /// 🎤 Live Audio Room
        ZegoUIKitPrebuiltLiveAudioRoom(
          appID: ZegoConfig.appID,
          appSign: ZegoConfig.appSign,
          userID: widget.userIdentification,
          userName: widget.userName ?? widget.userIdentification,
          roomID: widget.roomId,
          config: config,
        ),

        /// 🏷️ Room Name (editable if host)
        Positioned(
          top:70,
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
                    fontSize: 14, // adjust here if needed
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
              if (isHost)
                GestureDetector(
                  onTap: () => _editRoomName(context),
                  child: Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
            ],
          ),
        ),

        /// 🕹 Game Button
        Positioned(
          right: 20,
          bottom: 200,
          child: FloatingActionButton.extended(
            onPressed: () => widget.viewModel.showGameListModal(context),
            label: const Text('Games'),
            icon: const Icon(Icons.videogame_asset),
            backgroundColor: Colors.deepPurpleAccent,
          ),
        ),

        /// 🔌 End/Leave Button
        Positioned(
          top: 60,
          right: 20,
          child: GestureDetector(
            onTap: () async {
              final shouldExit = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(isHost ? 'End Room?' : 'Leave Room?'),
                  content: Text(isHost
                      ? 'Are you sure you want to end this room for everyone?'
                      : 'Are you sure you want to leave this room?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel',
                          style: TextStyle(color: AppColors.accentBlack)),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent),
                      child: Text(isHost ? 'End' : 'Leave',
                          style: const TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );

              if (shouldExit == true) {
                final roomService = widget.viewModel.roomService;
                final success = isHost
                    ? await roomService.endRoom(widget.roomId, widget.hostId)
                    : await roomService.leaveRoom(
                    widget.roomId, widget.userIdentification);

                if (success) {
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isHost
                          ? 'Failed to end the room.'
                          : 'Failed to leave the room.'),
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
              child:
              const Icon(Icons.power_settings_new, color: Colors.white, size: 28),
            ),
          ),
        ),
      ],
    );
  }
}
