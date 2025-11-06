import 'package:flutter/material.dart';
import 'package:kittyparty/features/profile/profile_pages/settings/VIPSettings_page.dart';
import 'package:kittyparty/features/profile/profile_pages/settings/bind_number.dart';
import 'package:kittyparty/features/profile/profile_pages/settings/language_page.dart';
import 'package:kittyparty/features/profile/profile_pages/settings/payment_pass_page.dart';
import 'package:kittyparty/features/profile/profile_pages/settings/reset_pass_page.dart';
import 'package:kittyparty/features/profile/profile_pages/settings/set_password_page.dart';
import 'package:provider/provider.dart';

// 🔹 Auth + Core Imports
import 'package:kittyparty/features/auth/view/login_selection.dart';
import '../../../core/constants/colors.dart';
import '../../../core/global_widgets/buttons/primary_button.dart';
import '../../../core/global_widgets/dialogs/dialog_info.dart';
import '../../../core/global_widgets/dialogs/dialog_loading.dart';
import '../../../core/utils/index_provider.dart';
import '../../../core/utils/user_provider.dart';
// 🔹 Feature Pages
import '../../livestream/widgets/game_modal.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool _isLoggingOut = false;

  /// ✅ Handles logout with confirmation and loading dialogs
  Future<void> _handleLogout(BuildContext context) async {
    if (_isLoggingOut) return;
    setState(() => _isLoggingOut = true);

    DialogInfo(
      headerText: "Quit KittyParty?",
      subText: "Are you sure you want to quit?",
      confirmText: "Confirm",
      onCancel: () {
        Navigator.of(context, rootNavigator: true).pop();
        setState(() => _isLoggingOut = false);
      },
      onConfirm: () async {
        Navigator.of(context, rootNavigator: true).pop(); // close dialog

        DialogLoading(subtext: "Logging out...").build(context);

        try {
          final userProvider = context.read<UserProvider>();
          await userProvider.logout();

          // ✅ Reset page index on logout
          Provider.of<PageIndexProvider>(context, listen: false).pageIndex = 0;

          if (!context.mounted) return;
          Navigator.of(context, rootNavigator: true).pop(); // close loading
          Navigator.pushNamedAndRemoveUntil(context, "/auth", (route) => false);
        } catch (e) {
          if (context.mounted) {
            Navigator.of(context, rootNavigator: true).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Logout failed: $e")),
            );
          }
        } finally {
          if (mounted) setState(() => _isLoggingOut = false);
        }
      },
    ).build(context);
  }

  /// ✅ Opens the Game Modal
  void _openGameListModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const GameListModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Setting',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      backgroundColor: const Color(0xfff8f8f8),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                // 🔹 Account Group
                _buildGroup([
                  Consumer<UserProvider>(
                    builder: (context, userProvider, _) {
                      final email = userProvider.currentUser?.email ?? 'No email';
                      final phoneNumber = userProvider.currentUser?.phoneNumber ?? 'No phone number';

                      return Column(
                        children: [
                          _buildItem(
                            'Change Email',
                            trailingText: email,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SetPasswordPage()),
                            ),
                          ),
                          _buildItem(
                            'Bind Phone Number',
                            trailingText: phoneNumber,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const BindNumberPage()),
                            ),
                          ),
                          _buildItem(
                            userProvider.currentUser?.passwordHash != null &&
                                userProvider.currentUser!.passwordHash!.isNotEmpty
                                ? 'Reset Password'
                                : 'Set Password',
                            onTap: () {
                              final hasPassword = userProvider.currentUser?.passwordHash != null &&
                                  userProvider.currentUser!.passwordHash!.isNotEmpty;

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => hasPassword
                                      ? const ResetPassPage()   // navigate to reset
                                      : const SetPasswordPage(),    // navigate to set
                                ),
                              );
                            },
                          ),

                          _buildItem(
                            'Payment Password',
                            trailingText: 'Modify',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const PaymentPassPage()),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ]),

                // 🔹 Preferences Group
                _buildGroup([
                  _buildItem(
                    'VIP Setting',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const VIPSettingsPage()),
                    ),
                  ),
                  _buildItem('Notification Setting', onTap: () {}),
                  _buildItem(
                    'Language',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LanguagePage()),
                    ),
                  ),
                ]),

                // 🔹 Privacy / Management Group
                _buildGroup([
                  _buildItem('Shield Manager', onTap: () {}),
                  _buildItem('Blacklist Management', onTap: () {}),
                ]),

                // 🔹 Info / Support Group
                _buildGroup([
                  _buildItem('Personal Information and Permissions', onTap: () {}),
                  _buildItem('Help', onTap: () {}),
                  _buildItem('Clear Cache', onTap: () {}),
                  _buildItem('About MoliParty', onTap: () {}),
                ]),
              ],
            ),
          ),

          // 🔹 Logout Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                text: _isLoggingOut ? 'Logging out...' : 'Logout',
                onPressed: _isLoggingOut ? null : () => _handleLogout(context),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // 🔹 Game Testing Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                text: "🎮 Game for Testing",
                onPressed: () async => _openGameListModal(context),
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // 🔸 Group Container
  Widget _buildGroup(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: List.generate(children.length, (index) {
          return Column(
            children: [
              children[index],
              if (index != children.length - 1)
                const Divider(
                  height: 1,
                  thickness: 0.5,
                  indent: 16,
                  endIndent: 16,
                ),
            ],
          );
        }),
      ),
    );
  }

  // 🔸 Reusable List Item
  Widget _buildItem(String title, {String? trailingText, VoidCallback? onTap}) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Text(
              trailingText,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
      onTap: onTap,
      visualDensity: const VisualDensity(vertical: -2),
    );
  }
}
