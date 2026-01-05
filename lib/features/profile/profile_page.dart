// lib/features/landing/view/profile_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kittyparty/features/landing/landing_widgets/profile_widgets/stat_items.dart';
import 'package:provider/provider.dart';

import '../../core/constants/colors.dart';
import '../../core/utils/user_provider.dart';
import '../landing/landing_widgets/profile_widgets/profile_cards.dart';
import '../landing/landing_widgets/profile_widgets/profile_gradient_background.dart';
import '../landing/landing_widgets/profile_widgets/profile_menu.dart';
import '../landing/viewmodel/profile_viewmodel.dart';
import '../landing/landing_widgets/profile_widgets/gender_badge.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  UserGender _mapGender(dynamic raw) {
    final v = (raw ?? '').toString().trim().toLowerCase();
    if (v == 'boy' || v == 'male' || v == 'm' || v == '1') return UserGender.male;
    return UserGender.female; // default
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

        return ChangeNotifierProvider(
          create: (_) => ProfileViewModel()..loadProfile(context),
          child: Consumer<ProfileViewModel>(
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
                      await Provider.of<ProfileViewModel>(context, listen: false)
                          .loadProfile(context);
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        vertical: 30,
                        horizontal: 16,
                      ),
                      child: Column(
                        children: [
                          // Profile Picture
                          GestureDetector(
                            onTap: () async {
                              final picker = ImagePicker();
                              final picked = await picker.pickImage(
                                source: ImageSource.gallery,
                              );
                              if (picked != null) {
                                await Provider.of<ProfileViewModel>(context, listen: false)
                                    .changeProfilePicture(
                                  context,
                                  File(picked.path),
                                );
                              }
                            },
                            child: CircleAvatar(
                              key: ValueKey(vm.userProfile?.profilePicture ?? 'default'),
                              radius: 40,
                              backgroundColor: AppColors.accentWhite,
                              backgroundImage: vm.profilePictureBytes != null
                                  ? MemoryImage(vm.profilePictureBytes!)
                                  : null,
                              child: vm.profilePictureBytes == null
                                  ? const Icon(Icons.person, size: 40, color: Colors.grey)
                                  : null,
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Name + Gender badge (beside name)
                          vm.isLoading
                              ? Container(
                            width: 120,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          )
                              : Row(
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
                              const SizedBox(width: 8),
                              GenderBadge(gender: gender, size: 20),
                            ],
                          ),

                          const SizedBox(height: 5),

                          // User ID
                          vm.isLoading
                              ? Container(
                            width: 80,
                            height: 14,
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          )
                              : Text(
                            'ID: $userId',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Bio
                          vm.isLoading
                              ? Container(
                            width: double.infinity,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          )
                              : (profile?.bio.isNotEmpty ?? false)
                              ? Text(
                            profile!.bio,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          )
                              : const SizedBox.shrink(),

                          const SizedBox(height: 10),

                          // Stats Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              StatItem(
                                label: "Following",
                                value: (vm.userSocial?.following ?? 0).toString(),
                              ),
                              StatItem(
                                label: "Fans",
                                value: (vm.userSocial?.fans ?? 0).toString(),
                              ),
                              StatItem(
                                label: "Friends",
                                value: (vm.userSocial?.friends ?? 0).toString(),
                              ),
                              StatItem(
                                label: "Visitors",
                                value: (vm.userSocial?.visitors ?? 0).toString(),
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
          ),
        );
      },
    );
  }
}
