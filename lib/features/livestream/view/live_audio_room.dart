import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/api/room_service.dart';
import '../../../core/services/api/userProfile_service.dart';
import '../../../core/utils/user_provider.dart';
import '../viewmodel/live_audio_room_viewmodel.dart';
import '../widgets/permission_denied.dart';
import '../widgets/user_id_missing.dart';
import '../widgets/zego_widget.dart';

class LiveAudioRoom extends StatelessWidget {
  final String roomId;
  final String hostId;
  final String roomName;
  final UserProvider userProvider;

  const LiveAudioRoom({
    super.key,
    required this.roomId,
    required this.hostId,
    required this.roomName,
    required this.userProvider,
  });

  @override
  Widget build(BuildContext context) {
    // create the profile service
    final profileService = UserProfileService();
    final roomService = RoomService(); // ✅ new instance


    return ChangeNotifierProvider(
      create: (_) => LiveAudioRoomViewmodel(
        userProvider: userProvider,
        profileService: profileService,
        roomService: roomService,
      )..init(roomId),
      child: Consumer<LiveAudioRoomViewmodel>(
        builder: (context, vm, _) {
          if (!vm.permissionChecked) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!vm.hasPermission) {
            return const PermissionDeniedWidget();
          }
          if (vm.userIdentification == null) {
            return const UserIdMissing();
          }

          return ZegoRoomWidget(
            roomId: roomId,
            hostId: hostId,
            roomName: roomName,
            userIdentification: vm.userIdentification!,
            userName: vm.userName,
            profileCache: vm.profileCache,
            viewModel: vm,
            fetchProfilePicture: vm.fetchProfilePicture,
          );
        },
      ),
    );
  }
}
