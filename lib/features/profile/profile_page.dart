import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/user_provider.dart';
import '../landing/landing_widgets/profile_widgets/profile_cards.dart';
import '../landing/landing_widgets/profile_widgets/profile_gradient_background.dart';
import '../landing/landing_widgets/profile_widgets/profile_menu.dart';
import '../landing/viewmodel/profile_viewmodel.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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

              // Display numeric userIdentification as fallback if username is empty
              final displayName = user.username.isNotEmpty
                  ? user.username
                  : profile?.userIdentification ?? user.userIdentification;

              final userId = profile?.userIdentification.isNotEmpty ?? false
                  ? profile!.userIdentification
                  : user.userIdentification;

              return ProfileGradientBackground(
                child: SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
                    child: Column(
                      children: [
                        // Profile Picture
                        GestureDetector(
                          onTap: () async {
                            final picker = ImagePicker();
                            final picked = await picker.pickImage(source: ImageSource.gallery);
                            if (picked != null) {
                              await vm.changeProfilePicture(context, File(picked.path));
                            }
                          },
                          child: CircleAvatar(
                            key: ValueKey(profile?.profilePicture ?? 'default'),
                            radius: 40,
                            backgroundColor: AppColors.accentWhite,
                            backgroundImage: vm.profilePictureBytes != null
                                ? MemoryImage(vm.profilePictureBytes!) as ImageProvider
                                : null,
                            child: vm.profilePictureBytes == null
                                ? const Icon(Icons.person, size: 40, color: Colors.grey)
                                : null,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Name
                        vm.isLoading
                            ? Container(
                          width: 120,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        )
                            : Text(
                          displayName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
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
                          style: const TextStyle(fontSize: 14, color: Colors.white70),
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

                        const SizedBox(height: 15),
                        const ProfileCards(),
                        const SizedBox(height: 20),
                        ProfileMenu(),
                      ],
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
