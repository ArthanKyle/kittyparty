import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kittyparty/features/auth/view/login_selection.dart';
import '../../../core/constants/colors.dart';
import '../../../core/global_widgets/buttons/primary_button.dart';
import '../../../core/global_widgets/dialogs/dialog_info.dart';
import '../../../core/global_widgets/dialogs/dialog_loading.dart';
import '../../../core/utils/index_provider.dart';
import '../../../core/utils/user_provider.dart';

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
                _buildGroup([
                  Consumer<UserProvider>(
                    builder: (context, userProvider, _) {
                      final email = userProvider.currentUser?.email ?? 'No email';
                      return _buildItem('Change Email', trailingText: email);
                    },
                  ),
                  _buildItem('Bind Phone Number'),
                  _buildItem('Reset password'),
                  _buildItem('Payment Password', trailingText: 'Modify'),
                ]),
                _buildGroup([
                  _buildItem('VIP Setting'),
                  _buildItem('Notification Setting'),
                  _buildItem('Language'),
                ]),
                _buildGroup([
                  _buildItem('Shield Manager'),
                  _buildItem('Blacklist Management'),
                ]),
                _buildGroup([
                  _buildItem('Personal Information and Permissions'),
                  _buildItem('Help'),
                  _buildItem('Clear Cache'),
                  _buildItem('About MoliParty'),
                ]),
              ],
            ),
          ),

          // ✅ Logout Button
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
          const SizedBox(height: 30),
        ],
      ),
    );
  }

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
                const Divider(height: 1, thickness: 0.5, indent: 16, endIndent: 16),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildItem(String title, {String? trailingText}) {
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
      onTap: () {},
      visualDensity: const VisualDensity(vertical: -2),
    );
  }
}
