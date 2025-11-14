import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Needed for Clipboard
import 'package:provider/provider.dart'; // Needed for UserProvider/ProfileViewModel
import '../../../core/utils/user_provider.dart';
import '../../landing/viewmodel/profile_viewmodel.dart';

class InvitePage extends StatefulWidget {
  const InvitePage({super.key});

  @override
  State<InvitePage> createState() => _InvitePageState();
}

class _InvitePageState extends State<InvitePage> {
  // Removed static _invitationCode. It will be fetched dynamically in build().

  // Updated function to accept the code string dynamically
  void _copyCodeToClipboard(BuildContext context, String code) {
    // Check if the code is available before copying
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
          content: Text('Invitation code copied to clipboard!'),
          duration: Duration(seconds: 1),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final user = userProvider.currentUser;

        // Dynamically fetch the invitation code from the current user
        final String invitationCode = user?.myInvitationCode ?? 'N/A'; // <-- Fetch is here

        if (userProvider.isLoading || user == null) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator(color: Colors.yellow)),
          );
        }

        // We use a Builder to get a new context that is a descendant of the ChangeNotifierProvider
        return ChangeNotifierProvider(
          create: (_) => ProfileViewModel()..loadProfile(context),
          child: Consumer<ProfileViewModel>(
            builder: (context, vm, _) {
              // 3. Get the profile picture bytes
              final profilePictureWidget = vm.profilePictureBytes != null
                  ? CircleAvatar(
                radius: 28,
                backgroundImage: MemoryImage(vm.profilePictureBytes!),
              )
                  : const CircleAvatar(
                radius: 28,
                backgroundImage: AssetImage('assets/image/Profile.png'),
              );

              return Scaffold(
                backgroundColor: Colors.black,
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      // 🔹 HEADER IMAGE
                      Image.asset(
                        'assets/image/GetCoins.png',
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),

                      const SizedBox(height: 10),

                      // 🔹 1ST SECTION: PROFILE + CODE
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6B4F2A), Color(0xFF3E2C13)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFFFD700),
                            width: 3,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                // 3. Dynamically loaded Profile Picture
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
                                // 1. Use the DYNAMIC Invitation Code
                                Text(
                                  invitationCode, // <-- Now dynamic
                                  style: const TextStyle(
                                    color: Colors.yellow,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // 2. Copy Button with dynamic function call
                            GestureDetector(
                              onTap: () => _copyCodeToClipboard(context, invitationCode), // <-- Dynamic code passed
                              child: Container(
                                width: double.infinity,
                                height: 40,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Colors.yellow, Colors.white],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.4),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                  border: Border.all(
                                    color: const Color(0xFFFFD700),
                                    width: 2,
                                  ),
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

                      // 🔹 2ND SECTION: EARNINGS, OBTAIN, COINS
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Earnings Button
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFBA68C8), Color(0xFF7B1FA2)],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFFFD700),
                                  width: 2,
                                ),
                              ),
                              child: const Text(
                                'Earnings',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            // Obtain + Coin Section
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 20),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Colors.orange, Colors.white],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFFFD700),
                                    width: 3,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Image.asset(
                                          'assets/icons/KPcoin.png',
                                          height: 24,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 🔹 3RD SECTION: RULES + ACCOUNT
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6B4F2A), Color(0xFF3E2C13)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFFFD700),
                            width: 3,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFBA68C8), Color(0xFF7B1FA2)],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0xFFFFD700),
                                    width: 2,
                                  ),
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
                                  colors: [Colors.yellow, Color(0xFFFFA000)],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFFFFD700),
                                  width: 2,
                                ),
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

                      // 🔹 DUMMY TEXT
                      Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3E2C13),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFFD700), width: 2),
                        ),
                        child: const Text(
                          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                              'Mauris vel mauris nec turpis porttitor feugiat. '
                              'Suspendisse potenti. Aenean facilisis lorem ut lorem 50.',
                          style: TextStyle(
                            color: Color(0xFFFFF8DC),
                            fontSize: 14,
                            height: 1.4,
                          ),
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
    );
  }
}