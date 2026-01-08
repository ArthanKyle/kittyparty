// lib/features/profile/profile_pages/level_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/api/wealth_service.dart';
import '../../../core/utils/profile_picture_helper.dart';
import '../../../core/utils/user_provider.dart';
import '../../landing/model/wealth.dart';
import '../../landing/viewmodel/profile_viewmodel.dart';
import '../../landing/viewmodel/wealth_viewmodel.dart';

class LevelPage extends StatefulWidget {
  const LevelPage({super.key});

  @override
  State<LevelPage> createState() => _LevelPageState();
}

class _LevelPageState extends State<LevelPage> {
  bool _didInit = false;

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

            final uid = user.userIdentification?.trim() ?? "";
            if (uid.isEmpty) {
              return const Center(
                child: Text('No UserIdentification', style: TextStyle(color: Colors.white)),
              );
            }

            return MultiProvider(
              providers: [
                ChangeNotifierProvider(
                  create: (context) => ProfileViewModel()..loadProfile(context),
                ),
                ChangeNotifierProvider(
                  create: (_) => WealthViewModel(
                    service: WealthService(),
                  ),
                ),
              ],
              child: Builder(
                builder: (context) {
                  WidgetsBinding.instance.addPostFrameCallback((_) async {
                    if (_didInit) return;
                    _didInit = true;

                    final wealthVm = context.read<WealthViewModel>();
                    if (wealthVm.status == null && !wealthVm.isLoading) {
                      await wealthVm.load(userIdentification: uid);
                    }
                  });

                  return Consumer2<ProfileViewModel, WealthViewModel>(
                    builder: (context, profileVm, wealthVm, _) {
                      return RefreshIndicator(
                        onRefresh: () => wealthVm.refresh(userIdentification: uid),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                          child: Column(
                            children: [
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

                              _goldInfoCard(
                                context,
                                user: user,
                                profileVm: profileVm,
                                wealthVm: wealthVm,
                              ),
                              const SizedBox(height: 18),

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

                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _goldInfoCard(
      BuildContext context, {
        required dynamic user, // replace with your actual User type
        required ProfileViewModel profileVm,
        required WealthViewModel wealthVm,
      }) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.currentUser!;
    final profileVm = Provider.of<ProfileViewModel>(context, listen: false);

    final profilePictureWidget = UserAvatarHelper.circleAvatar(
      userIdentification: user.userIdentification,
      displayName: user.fullName ?? user.username ?? "U",
      radius: 32,
      localBytes: profileVm.profilePictureBytes,
    );

    final WealthStatus? w = wealthVm.status;
    final int level = w?.level ?? 1;
    final int exp = w?.exp ?? 0;
    final int nextLevel = w?.nextLevel ?? (level + 1);
    final double progress = (w?.percentToNext ?? 0.0).clamp(0.0, 1.0);
    final int? nextReq = w?.nextLevelTotalRequired;
    final int remaining = w?.remainingToNext ?? 0;

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
          colors: [Color(0xFFB37A2E), Color(0xFFFFE9B6), Color(0xFFB37A2E)],
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
                  children: [
                    Text(
                      'LV.$level',
                      style: const TextStyle(
                        color: Color(0xFF3B2B19),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Wealth Value: $exp',
                      style: const TextStyle(
                        color: Color(0xFF4A351F),
                        fontSize: 14,
                      ),
                    ),
                    if (wealthVm.isLoading) ...const [
                      SizedBox(height: 6),
                      Text('Loading...', style: TextStyle(color: Color(0xFF4A351F), fontSize: 12)),
                    ],
                    if (!wealthVm.isLoading && wealthVm.error != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        wealthVm.error!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ],
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
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'LV.$level',
                style: const TextStyle(color: Color(0xFF52381E), fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.white.withOpacity(0.7),
                    color: const Color(0xFF8C5A2D),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'LV.$nextLevel',
                style: const TextStyle(color: Color(0xFF52381E), fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              w!.level >= 100
                  ? 'Max wealth level reached'
                  : 'Next milestone EXP: $nextReq (remaining: $remaining)',
              style: const TextStyle(
                color: Color(0xFF4C351F),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 8, top: 16),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFF8C5A2D), Color(0xFFFFE6A8), Color(0xFF8C5A2D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: const [
              BoxShadow(color: Colors.black54, blurRadius: 6, offset: Offset(0, 3)),
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
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                const Color(0xFF2D1A0E).withOpacity(0.9),
                const Color(0xFF3B2213).withOpacity(0.75),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            border: Border.all(color: Colors.black.withOpacity(0.4), width: 0.6),
          ),
          child: Text(
            content,
            style: const TextStyle(color: Color(0xFFEDD6B1), fontSize: 14, height: 1.5),
          ),
        ),
      ],
    );
  }
}
