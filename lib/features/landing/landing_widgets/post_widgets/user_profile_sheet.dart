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
    final currentUserId = currentUser?.userIdentification;
    final isMe = currentUserId == userId;

    if (currentUserId == null) {
      return const SizedBox.shrink();
    }

    return ChangeNotifierProvider(
      create: (_) => SocialViewModel()
        ..load(
          currentUserId: currentUserId,
          targetUserId: userId,
        ),
      child: Consumer<SocialViewModel>(
        builder: (context, vm, _) {
          final social = vm.social;

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
                    _count("Following", social?.following),
                    _count("Fans", social?.fans),
                    _count("Friends", social?.friends),
                  ],
                ),

                const SizedBox(height: 20),

                // ================= ACTION BUTTONS =================
                if (!isMe)
                  Row(
                    children: [
                      // -------- FOLLOW / UNFOLLOW --------
                      Expanded(
                        child: ElevatedButton(
                          onPressed: vm.isLoading
                              ? null
                              : () async {
                            if (vm.isFollowing) {
                              await vm.unfollow();
                            } else {
                              await vm.follow();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            vm.isFollowing ? Colors.grey : AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            vm.isFollowing ? "Unfollow" : "Follow",
                            style: const TextStyle(
                              color: AppColors.accentWhite,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      // -------- FRIEND / UNFRIEND --------
                      Expanded(
                        child: OutlinedButton(
                          onPressed: vm.isLoading
                              ? null
                              : () async {
                            if (vm.isFriend) {
                              await vm.unfriend();
                            } else {
                              await vm.addFriend();
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(
                              color: vm.isFriend
                                  ? Colors.redAccent
                                  : AppColors.primary,
                            ),
                          ),
                          child: Text(
                            vm.isFriend ? "Unfriend" : "Add Friend",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color:
                              vm.isFriend ? Colors.redAccent : AppColors.primary,
                            ),
                          ),
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

  // ================= COUNTER WIDGET =================
  Widget _count(String label, int? value) {
    return Column(
      children: [
        Text(
          "${value ?? 0}",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
