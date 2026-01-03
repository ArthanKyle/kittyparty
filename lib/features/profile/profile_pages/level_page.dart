import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/profile_picture_helper.dart';
import '../../../core/utils/user_provider.dart';
import '../../landing/viewmodel/profile_viewmodel.dart';

class LevelPage extends StatefulWidget {
  const LevelPage({super.key});

  @override
  State<LevelPage> createState() => _LevelPageState();
}

class _LevelPageState extends State<LevelPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2B160A),
      body: SafeArea(
        child: Consumer<UserProvider>(
          builder: (context, userProvider, _) {
            final user = userProvider.currentUser;

            if (userProvider.isLoading || user == null) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.yellow),
              );
            }

            return ChangeNotifierProvider(
              create: (_) => ProfileViewModel()..loadProfile(context),
              child: Consumer<ProfileViewModel>(
                builder: (context, vm, _) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    child: Column(
                      children: [
                        // 🔹 Top bar
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.maybePop(context),
                              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                            ),
                            const Expanded(
                              child: Text(
                                'Wealth Level',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 48),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // 🌟 Top Info Card (now uses profile picture widget)
                        _goldInfoCard(context),
                        const SizedBox(height: 18),

                        // 📜 Info Sections
                        _section(
                          title: 'How to upgrade',
                          content:
                          'For every gift of 1 gold coins, you can accumulate 1 experience point. The more experience points you accumulate, the higher your level will be.',
                        ),
                        _section(
                          title: 'Obtaining Conditions',
                          content:
                          '1. Users at Lv.1 and above can receive a level badge.\n2. Users at Lv.30 and above can unlock level privileges (room entry dazzling special effects).',
                        ),
                        _section(
                          title: 'Level Icon Description',
                          content:
                          'The level icon will be displayed on the room screen, personal profile page, and other places. The higher the level, the cooler the icon.',
                        ),
                        _section(
                          title: 'Wealth Level Special Selection Description',
                          content:
                          'Wealth level includes upgrading room entry dazzling special effects. The higher the level, the cooler the entry special effects.',
                        ),

                        const SizedBox(height: 24),

                        // 🧱 Table Placeholder
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF452415).withOpacity(0.6),
                                const Color(0xFF3A2215).withOpacity(0.35),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            children: const [
                              Text(
                                'Level        Icon',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'LV.1    [icon preview here]',
                                style: TextStyle(color: Colors.white54),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  // 🌟 GOLD INFO CARD
  Widget _goldInfoCard(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.currentUser;

    // if called before user is ready, keep old fallback
    if (user == null) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.45),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
          gradient: const LinearGradient(
            colors: [
              Color(0xFFB37A2E),
              Color(0xFFFFE9B6),
              Color(0xFFB37A2E),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: const [
            CircleAvatar(
              radius: 32,
              backgroundImage: AssetImage('assets/image/profile.png'),
            ),
          ],
        ),
      );
    }

    final vm = Provider.of<ProfileViewModel>(context, listen: false);

    final profilePictureWidget = UserAvatarHelper.circleAvatar(
      userIdentification: user.userIdentification,
      displayName: user.fullName ?? user.username ?? "U",
      radius: 32, // matches old CircleAvatar radius
      localBytes: vm.profilePictureBytes,
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.45),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        gradient: const LinearGradient(
          colors: [
            Color(0xFFB37A2E), // bronze
            Color(0xFFFFE9B6), // pale gold
            Color(0xFFB37A2E),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              profilePictureWidget,
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'LV.1',
                      style: TextStyle(
                        color: Color(0xFF3B2B19),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Wealth Value: 0',
                      style: TextStyle(
                        color: Color(0xFF4A351F),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF6D4C2D),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Rewards',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text(
                'LV.1',
                style: TextStyle(
                  color: Color(0xFF52381E),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: 0.0,
                    minHeight: 8,
                    backgroundColor: Colors.white.withOpacity(0.7),
                    color: const Color(0xFF8C5A2D),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'LV.2',
                style: TextStyle(
                  color: Color(0xFF52381E),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Wealth Value Required for upgrade: 3500',
              style: TextStyle(
                color: Color(0xFF4C351F),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🟡 GOLD LABEL + DARK BROWN BOX
Widget _section({required String title, required String content}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      // label with golden texture
      Container(
        margin: const EdgeInsets.only(bottom: 8, top: 16),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF8C5A2D), // bronze brown
              Color(0xFFFFE6A8), // pale yellow (shine)
              Color(0xFF8C5A2D),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),

      // content box (deep dark brown gradient)
      Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              Color(0xFF2D1A0E).withOpacity(0.9),
              Color(0xFF3B2213).withOpacity(0.75),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          border: Border.all(color: Colors.black.withOpacity(0.4), width: 0.6),
        ),
        child: Text(
          content,
          style: const TextStyle(
            color: Color(0xFFEDD6B1),
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ),
    ],
  );
}
}
