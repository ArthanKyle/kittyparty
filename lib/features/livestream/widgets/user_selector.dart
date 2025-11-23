import 'package:flutter/material.dart';
import 'package:zego_uikit/zego_uikit.dart';
import '../viewmodel/live_audio_room_viewmodel.dart';

class UserSelectorModal extends StatelessWidget {
  final LiveAudioRoomViewmodel viewModel;

  const UserSelectorModal({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final users = ZegoUIKit().getAllUsers();

    return Container(
      height: 420,
      decoration: const BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(100),
            ),
          ),

          const SizedBox(height: 15),
          const Text(
            "Select a Receiver",
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),

          Expanded(
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (_, index) {
                final user = users[index];
                final bytes = viewModel.profileCache[user.id];

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.white24,
                    backgroundImage: bytes != null ? MemoryImage(bytes) : null,
                    child: bytes == null
                        ? Text(
                      user.name.isEmpty ? '?' : user.name[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    )
                        : null,
                  ),
                  title: Text(
                    user.name,
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context, user.id);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
