import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/global_widgets/dialogs/dialog_info.dart';
import '../../../../core/global_widgets/dialogs/dialog_loading.dart';
import '../../../../core/utils/user_provider.dart';
import '../../../landing/landing_widgets/landing_widgets/room_card.dart';
import '../../../landing/landing_widgets/landing_widgets/section_title.dart';
import '../../../livestream/view/live_audio_room.dart';
import '../../viewmodel/landing_viewmodel.dart';

class MineTab extends StatefulWidget {
  const MineTab({super.key});

  @override
  State<MineTab> createState() => _MineTabState();
}

class _MineTabState extends State<MineTab> {
  @override
  void initState() {
    super.initState();
    _loadMyRooms();
  }

  void _loadMyRooms() {
    final userProvider = context.read<UserProvider>();
    final viewModel = context.read<LandingViewModel>();

    if (userProvider.currentUser != null) {
      viewModel.fetchMyRooms(userProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final viewModel = context.watch<LandingViewModel>();

    if (userProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final user = userProvider.currentUser;
    if (user == null) {
      return const Center(child: Text("Not logged in"));
    }

    final rooms = viewModel.myRooms;
    final room = rooms.isNotEmpty ? rooms.first : null;

    return RefreshIndicator(
      onRefresh: () async => _loadMyRooms(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          const SectionTitle('My Room'),
          const SizedBox(height: 8),
          if (room != null)
            RoomCard(
              room: room,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LiveAudioRoom(
                      roomId: room.id!,
                      hostId: room.hostId,
                      roomName: room.roomName,
                      userProvider: userProvider, // only this is needed
                    ),
                  ),
                );
              },
            )
          else
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => _createRoomDialog(context, viewModel, userProvider),
              child: const Text(
                "Create My Room",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _createRoomDialog(BuildContext context, LandingViewModel viewModel, UserProvider userProvider) {
    DialogInfo(
      headerText: "Create Room?",
      subText: "You don’t have a room yet. Would you like to create one now?",
      confirmText: "Create",
      onCancel: () => Navigator.of(context, rootNavigator: true).pop(),
      onConfirm: () async {
        Navigator.of(context, rootNavigator: true).pop();
        DialogLoading(subtext: "Creating room...").build(context);

        final room = await viewModel.createRoomForUser(userProvider, "My Room");

        Navigator.of(context, rootNavigator: true).pop(); // Close loading

        DialogInfo(
          headerText: room != null ? "Room Created" : "Failed",
          subText: room != null
              ? "Your room has been created successfully!"
              : "Could not create your room. Try again.",
          confirmText: "OK",
          onConfirm: () {
            Navigator.of(context, rootNavigator: true).pop();
            if (room != null) _loadMyRooms(); // Refresh after creation
          },
          onCancel: () => Navigator.of(context, rootNavigator: true).pop(),
        ).build(context);
      },
    ).build(context);
  }
}
