import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/constants/colors.dart';
import '../../core/global_widgets/dialogs/dialog_loading.dart';
import '../../core/utils/profile_picture_helper.dart';
import '../../core/utils/user_provider.dart';

import '../landing/landing_widgets/profile_widgets/profile_cards.dart';
import '../landing/landing_widgets/profile_widgets/profile_gradient_background.dart';
import '../landing/landing_widgets/profile_widgets/profile_menu.dart';
import '../landing/landing_widgets/profile_widgets/stat_items.dart';
import '../landing/landing_widgets/profile_widgets/gender_badge.dart';

import '../landing/viewmodel/profile_viewmodel.dart';
import '../landing/viewmodel/inventory_viewmodel.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _bound = false;

  UserGender _mapGender(dynamic raw) {
    if (raw == null) return UserGender.female;
    final v = raw.toString().trim().toLowerCase();
    if (v == 'male' || v == 'm' || v == '1' || v == 'boy') {
      return UserGender.male;
    }
    return UserGender.female;
  }

  @override
  void initState() {
    super.initState();

    /// 🔥 ALL side-effects happen AFTER first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileVM = context.read<ProfileViewModel>();
      final itemVM = context.read<ItemViewModel>();

      /// Load profile ONCE
      profileVM.loadProfile(context);

      /// Bind inventory → avatar frame (ONCE)
      if (!_bound) {
        _bound = true;

        // initial sync
        profileVM.syncFromInventory(itemVM.inventory);

        // react to future inventory changes
        itemVM.addListener(() {
          profileVM.syncFromInventory(itemVM.inventory);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        if (userProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!userProvider.isLoggedIn) {
          return const Center(child: Text("No logged in user"));
        }

        final user = userProvider.currentUser!;

        return Consumer<ProfileViewModel>(
          builder: (context, vm, _) {
            final profile = vm.userProfile;

            final displayName = user.username.isNotEmpty
                ? user.username
                : profile?.userIdentification ?? user.userIdentification;

            final userId = (profile?.userIdentification.isNotEmpty ?? false)
                ? profile!.userIdentification
                : user.userIdentification;

            final gender = _mapGender(user.gender);

            return ProfileGradientBackground(
              child: SafeArea(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await vm.loadProfile(context);

                    final itemVM = context.read<ItemViewModel>();
                    vm.syncFromInventory(itemVM.inventory);
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      vertical: 30,
                      horizontal: 16,
                    ),
                    child: Column(
                      children: [
                        // ================= AVATAR =================
                        GestureDetector(
                          onTap: () async {
                            final picker = ImagePicker();
                            final picked = await picker.pickImage(
                              source: ImageSource.gallery,
                            );

                            if (picked == null || !context.mounted) return;

                            DialogLoading(
                              subtext: "Uploading your profile picture....",
                            ).build(context);

                            try {
                              await vm.changeProfilePicture(
                                context,
                                File(picked.path),
                              );
                            } finally {
                              if (context.mounted) {
                                Navigator.of(
                                  context,
                                  rootNavigator: true,
                                ).pop();
                              }
                            }
                          },
                          child: UserAvatarHelper.circleAvatar(
                            userIdentification: user.userIdentification,
                            displayName: displayName,
                            radius: 40,
                            localBytes: vm.profilePictureBytes,
                            frameAsset: vm.avatarFrameAsset, // ✅ FRAME MOUNTS
                          ),
                        ),

                        const SizedBox(height: 10),

                        // ================= NAME =================
                        vm.isLoading
                            ? Container(
                          width: 140,
                          height: 22,
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        )
                            : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              displayName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 6),
                            GenderBadge(
                              gender: gender,
                              size: 12,
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        // ================= VIP / LEVEL =================
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _InfoBadge(
                              icon: Icons.verified,
                              text: 'VIP ${user.vipLevel}',
                              color: const Color(0xFF19C37D),
                            ),
                            const SizedBox(width: 8),
                            _InfoBadge(
                              icon: Icons.star,
                              text: 'Lv ${user.wealthLevel}',
                              color: const Color(0xFF19C37D),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        // ================= USER ID =================
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'ID: $userId',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () async {
                                await Clipboard.setData(
                                  ClipboardData(text: userId),
                                );
                              },
                              child: const Icon(
                                Icons.copy_rounded,
                                size: 11,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // ================= BIO =================
                        if ((profile?.bio.isNotEmpty ?? false))
                          Text(
                            profile!.bio,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontStyle: FontStyle.italic,
                            ),
                          ),

                        const SizedBox(height: 12),

                        // ================= STATS =================
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            StatItem(
                              label: "Following",
                              value:
                              (vm.userSocial?.following ?? 0).toString(),
                            ),
                            StatItem(
                              label: "Fans",
                              value:
                              (vm.userSocial?.fans ?? 0).toString(),
                            ),
                            StatItem(
                              label: "Friends",
                              value:
                              (vm.userSocial?.friends ?? 0).toString(),
                            ),
                            StatItem(
                              label: "Visitors",
                              value:
                              (vm.userSocial?.visitors ?? 0).toString(),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                        const ProfileCards(),
                        const SizedBox(height: 20),
                        ProfileMenu(),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ================= BADGE =================
class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _InfoBadge({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
