import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
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

    Clipboard.setData(ClipboardData(text: code)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invitation code copied!'),
          duration: Duration(seconds: 1),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          final user = userProvider.currentUser;
          final String invitationCode = user?.myInvitationCode ?? 'N/A';

          if (userProvider.isLoading || user == null) {
            return const Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                child: CircularProgressIndicator(color: Colors.yellow),
              ),
            );
          }

          return ChangeNotifierProvider(
            create: (_) => ProfileViewModel()..loadProfile(context),
            child: Consumer<ProfileViewModel>(
              builder: (context, vm, _) {
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
                        // ✅ Main content
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              Image.asset(
                                'assets/image/GetCoins.png',
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),

                              const SizedBox(height: 10),

                              Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF6B4F2A),
                                      Color(0xFF3E2C13)
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: const Color(0xFFFFD700), width: 3),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        profilePictureWidget,
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
                                      onTap: () => _copyCodeToClipboard(
                                          context, invitationCode),
                                      child: Container(
                                        width: double.infinity,
                                        height: 40,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Colors.yellow,
                                              Colors.white
                                            ],
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                          ),
                                          borderRadius:
                                          BorderRadius.circular(8),
                                          border: Border.all(
                                            color: const Color(0xFFFFD700),
                                            width: 2,
                                          ),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.white54,
                                              blurRadius: 10,
                                              spreadRadius: 2,
                                            )
                                          ],
                                        ),
                                        child: const Text(
                                          'Copy',
                                          style: TextStyle(
                                            color: Color(0xFF4B0082),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 20),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFFBA68C8),
                                            Color(0xFF7B1FA2)
                                          ],
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                        ),
                                        borderRadius:
                                        BorderRadius.circular(8),
                                        border: Border.all(
                                            color: const Color(0xFFFFD700),
                                            width: 2),
                                      ),
                                      child: const Text(
                                        'Earnings',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        margin: const EdgeInsets.only(left: 8),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 20),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Colors.orange,
                                              Colors.white
                                            ],
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                          ),
                                          borderRadius:
                                          BorderRadius.circular(12),
                                          border: Border.all(
                                            color: const Color(0xFFFFD700),
                                            width: 3,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'Obtain',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                const Text(
                                                  '0',
                                                  style: TextStyle(
                                                    fontWeight:
                                                    FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Image.asset(
                                                    'assets/icons/KPcoin.png',
                                                    height: 24),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF6B4F2A),
                                      Color(0xFF3E2C13)
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: const Color(0xFFFFD700), width: 3),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFFBA68C8),
                                              Color(0xFF7B1FA2)
                                            ],
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                          ),
                                          borderRadius:
                                          BorderRadius.circular(10),
                                          border: Border.all(
                                              color: const Color(0xFFFFD700),
                                              width: 2),
                                        ),
                                        child: const Text(
                                          'Rules',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 16),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Colors.yellow,
                                            Color(0xFFFFA000)
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                        borderRadius:
                                        BorderRadius.circular(10),
                                        border: Border.all(
                                            color: const Color(0xFFFFD700),
                                            width: 2),
                                      ),
                                      child: const Text(
                                        'Account',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Container(
                                margin: const EdgeInsets.all(16),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF3E2C13),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: const Color(0xFFFFD700), width: 2),
                                ),
                                child: inviteRulesCard(),
                              ),
                            ],
                          ),
                        ),

                        // ✅ ArrowBack overlay (top-left)
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
        },
      ),
    );
  }
  Widget inviteRulesCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3E2C13), Color(0xFF6B4F2A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFFFD700), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Invite friends to recharge and get coins (valid for 30 days)",
            style: TextStyle(color: Color(0xFFFFF8DC), fontSize: 13),
          ),
          SizedBox(height: 14),

          Text(
            "Direct Invite Rewards",
            style: TextStyle(
              color: Colors.yellow,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),

          Text(
            "• <70,000 coins → 1%\n"
                "• 70,000–699,999 coins → 2%\n"
                "• ≥700,000 coins → 4%",
            style: TextStyle(color: Colors.white, height: 1.4),
          ),

          SizedBox(height: 14),

          Text(
            "Indirect Invite Rewards",
            style: TextStyle(
              color: Colors.yellow,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),

          Text(
            "• ≥70,000 coins → 0.5%\n"
                "• ≥700,000 coins → 1%",
            style: TextStyle(color: Colors.white, height: 1.4),
          ),
        ],
      ),
    );
  }
}
