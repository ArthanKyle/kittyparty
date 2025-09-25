import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/user_provider.dart';
import '../profile_widgets/profile_cards.dart';
import '../profile_widgets/profile_gradient_background.dart';
import '../profile_widgets/profile_menu.dart';
import '../profile_widgets/stat_items.dart';
import '../viewmodel/profile_viewmodel.dart';

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
              final displayName = user.username.isNotEmpty
                  ? user.username
                  : (profile?.userId ?? "N/A");
              final userId =
              user.userIdentification.isNotEmpty ? user.userIdentification : (profile?.userId ?? "N/A");

              return ProfileGradientBackground(
                child: SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
                    child: Column(
                      children: [
                        // 👤 Profile Picture
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

                        // Stats
                        vm.isLoading
                            ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(
                            4,
                                (_) => Container(
                              width: 50,
                              height: 14,
                              color: Colors.white24,
                            ),
                          ),
                        )
                            : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: const [
                            StatItem(label: 'Following', value: '0'),
                            StatItem(label: 'Fans', value: '0'),
                            StatItem(label: 'Friends', value: '0'),
                            StatItem(label: 'Visitors', value: '0'),
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
              );
            },
          ),
        );
      },
    );
  }
}
