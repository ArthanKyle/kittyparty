import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../core/constants/colors.dart';
import '../../core/utils/profile_picture_helper.dart';
import '../../core/utils/user_provider.dart';
import '../landing/viewmodel/agency_viewmodel.dart';
import '../landing/viewmodel/profile_viewmodel.dart';
import 'edit_personal_information_page.dart';

class UserInformationPage extends StatelessWidget {
  final ProfileViewModel vm;

  const UserInformationPage({
    super.key,
    required this.vm,
  });

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().currentUser;

    // ================= SAFE GUARD =================
    if (user == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0B1C26),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return AnimatedBuilder(
      animation: vm,
      builder: (context, _) {
        final profile = vm.userProfile;
        final partner = vm.partnerUser;
        final agencyVM = context.watch<AgencyViewModel>();

        final bio = profile?.bio;
        final album = profile?.album ?? [];

        return Scaffold(
          backgroundColor: const Color(0xFF0B1C26),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              "User Information",
              style: TextStyle(color: AppColors.accentWhite),
            ),
            leading: const BackButton(color: Colors.white),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditPersonalInformationPage(vm: vm),
                    ),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // ================= HEADER =================
                Column(
                  children: [
                    UserAvatarHelper.circleAvatar(
                      userIdentification: user.userIdentification,
                      displayName: user.username,
                      radius: 55,
                      localBytes: vm.profilePictureBytes,
                      frameUrl: vm.avatarFrameAsset,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user.username,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _badge("VIP ${user.vipLevel}"),
                        const SizedBox(width: 6),
                        _badge("Lv ${user.wealthLevel}"),
                        if (agencyVM.myAgency != null) ...[
                          const SizedBox(width: 6),
                          _badge(agencyVM.isOwner ? "Agency Owner" : "Agent"),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${user.countryCode} | ${profile?.birthday ?? '—'}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      (bio != null && bio.isNotEmpty)
                          ? bio
                          : "This person left nothing behind~",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _stat("Following", vm.userSocial?.following ?? 0),
                        _stat("Fans", vm.userSocial?.fans ?? 0),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ================= TABS =================
                Row(
                  children: [
                    _tab("Profile", true),
                    const SizedBox(width: 16),
                    _tab("Posts", false),
                  ],
                ),

                const SizedBox(height: 16),

                // ================= CP =================
                Container(
                  height: 150,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3A7BD5), Color(0xFF00D2FF)],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      UserAvatarHelper.circleAvatar(
                        userIdentification: user.userIdentification,
                        displayName: user.username,
                        radius: 55,
                        localBytes: vm.profilePictureBytes,
                        frameUrl: vm.avatarFrameAsset,
                      ),
                      const SizedBox(width: 14),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.favorite, color: Colors.white, size: 22),
                          SizedBox(height: 6),
                          Text(
                            "Waiting for love",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      partner != null
                          ? UserAvatarHelper.circleAvatar(
                        userIdentification: partner.userIdentification,
                        displayName: partner.username,
                        radius: 55,
                        frameUrl: "assets/frames/cp_frame.png",
                      )
                          : UserAvatarHelper.circleAvatar(
                        userIdentification: user.userIdentification,
                        displayName: "Waiting",
                        radius: 55,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ================= ALBUM =================
                _sectionTitle("Album"),
                const SizedBox(height: 8),
                if (album.isNotEmpty)
                  SizedBox(
                    height: 80,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: album.length,
                      itemBuilder: (_, i) => ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          album[i],
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      separatorBuilder: (_, __) =>
                      const SizedBox(width: 8),
                    ),
                  )
                else
                  const Text(
                    "No album data",
                    style: TextStyle(color: Colors.white54),
                  ),

                const SizedBox(height: 24),

                // ================= AGENCY =================
                if (agencyVM.myAgency != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                      ),
                    ),
                    child: Row(
                      children: [
                        _agencyCoverImage(agencyVM.myAgency!.media),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Agency Name: ${agencyVM.myAgency!.name}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Agency ID: ${agencyVM.myAgency!.agencyCode}\n"
                                    "Agent ID: ${user.userIdentification}",
                                style:
                                const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  // ================= HELPERS =================

  static Widget _badge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  static Widget _stat(String label, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Text(
            value.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ],
      ),
    );
  }

  static Widget _tab(String text, bool active) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: TextStyle(
            color: active ? Colors.white : Colors.white54,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        if (active)
          Container(
            margin: const EdgeInsets.only(top: 4),
            height: 2,
            width: 24,
            color: Colors.blueAccent,
          ),
      ],
    );
  }

  static Widget _sectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          color: Colors.blueAccent,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// ================= AGENCY IMAGE =================

Widget _agencyCoverImage(List<dynamic> media) {
  final base = dotenv.env['BASE_URL'];
  String? imageUrl;

  if (base != null &&
      media.isNotEmpty &&
      media.first is Map<String, dynamic>) {
    final id = media.first['id']?.toString();
    if (id != null && id.isNotEmpty) {
      imageUrl = "$base/media/$id";
    }
  }

  return ClipRRect(
    borderRadius: BorderRadius.circular(10),
    child: Container(
      width: 64,
      height: 64,
      color: Colors.black26,
      child: imageUrl != null
          ? Image.network(imageUrl, fit: BoxFit.cover)
          : const Icon(Icons.image_not_supported,
          color: Colors.white54),
    ),
  );
}
