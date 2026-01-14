import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/global_widgets/gradient_background/gradient_background.dart';
import '../../../core/utils/profile_picture_helper.dart';
import '../../../core/utils/user_provider.dart';
import '../../auth/widgets/arrow_back.dart';
import '../../landing/viewmodel/profile_viewmodel.dart';

class InvitePage extends StatefulWidget {
  const InvitePage({super.key});

  @override
  State<InvitePage> createState() => _InvitePageState();
}

class _InvitePageState extends State<InvitePage> {
  @override
  void initState() {
    super.initState();

    // Load invite earnings ONCE
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileViewModel>().fetchInviteEarnings(context);
    });
  }

  void _copyCodeToClipboard(BuildContext context, String code) {
    if (code == 'N/A' || code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: No invitation code available.'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Invitation code copied!'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Consumer2<UserProvider, ProfileViewModel>(
        builder: (context, userProvider, vm, _) {
          final user = userProvider.currentUser;
          final invitationCode = user?.myInvitationCode ?? 'N/A';

          if (userProvider.isLoading || user == null || vm.isLoading) {
            return const Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                child: CircularProgressIndicator(color: Colors.yellow),
              ),
            );
          }

          final profilePictureWidget = UserAvatarHelper.circleAvatar(
            userIdentification: user.userIdentification,
            displayName: user.fullName ?? user.username ?? "U",
            radius: 28,
            localBytes: vm.profilePictureBytes,
          );

          return Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/image/GetCoins.png',
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),

                        const SizedBox(height: 10),

                        // ───────── My Code Card ─────────
                        _codeCard(
                          profilePictureWidget,
                          invitationCode,
                        ),

                        // ───────── Earnings ─────────
                        _earningsCard(vm.inviteEarnings),

                        // ───────── Rules / Account Buttons ─────────
                        _rulesButtons(),

                        // ───────── Invite Rules ─────────
                        inviteRulesCard(),
                      ],
                    ),
                  ),

                  Positioned(
                    top: 6,
                    left: 6,
                    child: ArrowBack(
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ================= UI PARTS =================

  Widget _codeCard(Widget avatar, String invitationCode) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: _goldCardDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              avatar,
              const SizedBox(width: 12),
              const Text(
                'My Code',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                invitationCode,
                style: const TextStyle(
                  color: Colors.yellow,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => _copyCodeToClipboard(context, invitationCode),
            child: _goldButton("Copy"),
          ),
        ],
      ),
    );
  }

  Widget _earningsCard(int coins) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _purpleTag("Earnings"),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: _goldCardDecoration(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Obtain',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Text(
                        coins.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Image.asset('assets/icons/KPcoin.png', height: 24),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rulesButtons() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: _goldCardDecoration(),
      child: Row(
        children: [
          Expanded(child: _purpleTag("Rules")),
          const SizedBox(width: 8),
          _goldTag("Account"),
        ],
      ),
    );
  }

  Widget inviteRulesCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(14),
      decoration: _goldCardDecoration(),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Invite friends to recharge and get coins (valid for 30 days)",
            style: TextStyle(color: Color(0xFFFFF8DC), fontSize: 13),
          ),
          SizedBox(height: 14),
          Text(
            "Direct Invite Rewards",
            style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 6),
          Text(
            "• <70,000 coins → 1%\n"
                "• 70,000–699,999 coins → 2%\n"
                "• ≥700,000 coins → 4%",
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 14),
          Text(
            "Indirect Invite Rewards",
            style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 6),
          Text(
            "• ≥70,000 coins → 0.5%\n"
                "• ≥700,000 coins → 1%",
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  // ================= STYLES =================

  BoxDecoration _goldCardDecoration() => BoxDecoration(
    gradient: const LinearGradient(
      colors: [Color(0xFF6B4F2A), Color(0xFF3E2C13)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: const Color(0xFFFFD700), width: 3),
  );

  Widget _goldButton(String text) => Container(
    height: 40,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Colors.yellow, Colors.white],
      ),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: Color(0xFF4B0082),
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  Widget _purpleTag(String text) => Container(
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFFBA68C8), Color(0xFF7B1FA2)],
      ),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      text,
      style: const TextStyle(color: Colors.white),
    ),
  );

  Widget _goldTag(String text) => Container(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Colors.yellow, Color(0xFFFFA000)],
      ),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      text,
      style: const TextStyle(color: Colors.white),
    ),
  );
}
