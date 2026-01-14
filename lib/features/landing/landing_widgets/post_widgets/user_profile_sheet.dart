import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/utils/profile_picture_helper.dart';
import '../../../../core/utils/user_provider.dart';
import '../../viewmodel/social_viewmodel.dart';

class UserProfileSheet extends StatelessWidget {
  final String userId;
  final String displayName;
  final String? avatarUrl;

  const UserProfileSheet({
    super.key,
    required this.userId,
    required this.displayName,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    final userProvider = context.read<UserProvider>();
    final currentUser = userProvider.currentUser;
    final isMe = currentUser?.userIdentification == userId;

    return ChangeNotifierProvider(
      create: (_) => SocialViewModel()..load(userId),
      child: Consumer<SocialViewModel>(
        builder: (_, vm, __) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ================= AVATAR =================
                UserAvatarHelper.circleAvatar(
                  userIdentification: userId,
                  displayName: displayName,
                  localBytes: isMe ? userProvider.profilePictureBytes : null,
                  radius: 36,
                ),

                const SizedBox(height: 10),

                // ================= NAME =================
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                // ================= SOCIAL COUNTS =================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _count("Following", vm.social?.following),
                    _count("Fans", vm.social?.fans),
                    _count("Friends", vm.social?.friends),
                  ],
                ),

                const SizedBox(height: 20),

                // ================= ACTIONS =================
                if (!isMe)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: vm.toggleFollow,
                          child: Text(
                            vm.isFollowing ? "Unfollow" : "Follow",
                            style: const TextStyle(
                              color: AppColors.accentWhite,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            // friend request flow (future)
                          },
                          child: const Text("Add Friend"),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ================= HELPER =================
  Widget _count(String label, int? value) {
    return Column(
      children: [
        Text(
          "${value ?? 0}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(label),
      ],
    );
  }
}
