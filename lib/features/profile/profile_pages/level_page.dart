import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/api/charm_service.dart';
import '../../../core/services/api/wealth_service.dart';
import '../../../core/utils/profile_picture_helper.dart';
import '../../../core/utils/user_provider.dart';
import '../../landing/model/wealth.dart';
import '../../landing/viewmodel/charm_viewmodel.dart';
import '../../landing/viewmodel/profile_viewmodel.dart';
import '../../landing/viewmodel/wealth_viewmodel.dart';

class LevelPage extends StatefulWidget {
  const LevelPage({super.key});

  @override
  State<LevelPage> createState() => _LevelPageState();
}

class _LevelPageState extends State<LevelPage>
    with SingleTickerProviderStateMixin {
  bool _didInit = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0E22),
      body: SafeArea(
        child: Consumer<UserProvider>(
          builder: (context, userProvider, _) {
            final user = userProvider.currentUser;

            if (userProvider.isLoading || user == null) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            final uid = user.userIdentification?.trim() ?? "";
            if (uid.isEmpty) {
              return const Center(
                child: Text(
                  'No UserIdentification',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            return MultiProvider(
              providers: [
                ChangeNotifierProvider(
                  create: (_) => ProfileViewModel()..loadProfile(context),
                ),
                ChangeNotifierProvider(
                  create: (_) =>
                      WealthViewModel(service: WealthService()),
                ),
                ChangeNotifierProvider(
                  create: (_) =>
                      CharmViewModel(service: CharmService()),
                ),
              ],
              child: Builder(
                builder: (context) {
                  WidgetsBinding.instance.addPostFrameCallback((_) async {
                    if (_didInit) return;
                    _didInit = true;

                    await context
                        .read<WealthViewModel>()
                        .load(userIdentification: uid);

                    await context
                        .read<CharmViewModel>()
                        .load(userIdentification: uid);
                  });

                  return Column(
                    children: [
                      // ================= HEADER =================
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.maybePop(context),
                            icon: const Icon(Icons.arrow_back_ios,
                                color: Colors.white),
                          ),
                          const Expanded(
                            child: Text(
                              'Level',
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

                      // ================= TABS =================
                      TabBar(
                        controller: _tabController,
                        indicatorColor: Colors.white,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.white54,
                        tabs: const [
                          Tab(text: 'Wealth Level'),
                          Tab(text: 'Charm Level'),
                        ],
                      ),

                      // ================= CONTENT =================
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildTab(
                              context,
                              isCharm: false,
                              user: user,
                              uid: uid,
                            ),
                            _buildTab(
                              context,
                              isCharm: true,
                              user: user,
                              uid: uid,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // TAB CONTENT
  // ============================================================
  Widget _buildTab(
      BuildContext context, {
        required bool isCharm,
        required dynamic user,
        required String uid,
      }) {
    final profileVm = context.watch<ProfileViewModel>();
    final WealthStatus? status = isCharm
        ? context.watch<CharmViewModel>().status
        : context.watch<WealthViewModel>().status;

    return RefreshIndicator(
      onRefresh: () async {
        if (isCharm) {
          await context
              .read<CharmViewModel>()
              .refresh(userIdentification: uid);
        } else {
          await context
              .read<WealthViewModel>()
              .refresh(userIdentification: uid);
        }
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Column(
          children: [
            _levelCard(
              context,
              isCharm: isCharm,
              user: user,
              profileVm: profileVm,
              status: status,
            ),
            const SizedBox(height: 18),
            _section(
              title: 'How to upgrade',
              content: isCharm
                  ? 'For every gift of gold coins you receive, you gain charm points.'
                  : 'For every gold coin you spend, you gain wealth experience.',
              isCharm: isCharm,
            ),
            _section(
              title: 'Obtaining Conditions',
              content:
              'Lv.1+ unlocks badge\nLv.30+ unlocks entry effects',
              isCharm: isCharm,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // LEVEL CARD (WEALTH / CHARM)
  // ============================================================
  Widget _levelCard(
      BuildContext context, {
        required bool isCharm,
        required dynamic user,
        required ProfileViewModel profileVm,
        required WealthStatus? status,
      }) {
    if (status == null) {
      return const SizedBox(
        height: 140,
        child: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    final level = status.level;
    final exp = status.exp;
    final progress = status.percentToNext.clamp(0.0, 1.0);

    final profilePictureWidget = UserAvatarHelper.circleAvatar(
      userIdentification: user.userIdentification,
      displayName: user.fullName ?? user.username ?? "U",
      radius: 32,
      localBytes: profileVm.profilePictureBytes,
    );

    final gradient = isCharm
        ? const LinearGradient(
      colors: [
        Color(0xFF2E1147),
        Color(0xFF5B2A86),
        Color(0xFF2E1147),
      ],
    )
        : const LinearGradient(
      colors: [
        Color(0xFFB37A2E),
        Color(0xFFFFE9B6),
        Color(0xFFB37A2E),
      ],
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: gradient,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.45),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              profilePictureWidget,
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LV.$level',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isCharm
                          ? Colors.white
                          : const Color(0xFF3B2B19),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${isCharm ? "Charm" : "Wealth"} Value: $exp',
                    style: TextStyle(
                      fontSize: 14,
                      color:
                      isCharm ? Colors.white70 : const Color(0xFF4A351F),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Colors.white24,
            color: isCharm
                ? const Color(0xFFB46BFF)
                : const Color(0xFF8C5A2D),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION
  // ============================================================
  Widget _section({
    required String title,
    required String content,
    required bool isCharm,
  }) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            color: isCharm ? Colors.purpleAccent : Colors.amberAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(color: Colors.white70),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
