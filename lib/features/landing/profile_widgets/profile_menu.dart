import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../../core/global_widgets/dialogs/dialog_info.dart';
import '../../../core/global_widgets/dialogs/dialog_loading.dart';
import '../../../core/utils/user_provider.dart';

class ProfileMenu extends StatelessWidget {
  final List<Map<String, dynamic>> menuItems = [
    {'label': 'My Room', 'icon': FontAwesomeIcons.house},
    {'label': 'Agency', 'icon': FontAwesomeIcons.shield},
    {'label': 'My Collection', 'icon': FontAwesomeIcons.star},
    {'label': 'Daily Tasks', 'icon': FontAwesomeIcons.calendar},
    {'label': 'My Medals', 'icon': FontAwesomeIcons.medal},
    {'label': 'Invite', 'icon': FontAwesomeIcons.userPlus},
    {'label': 'My Level', 'icon': FontAwesomeIcons.arrowTrendUp},
    {'label': 'Mall', 'icon': FontAwesomeIcons.shirt},
    {'label': 'My Item', 'icon': FontAwesomeIcons.cube},
    {'label': 'Setting', 'icon': FontAwesomeIcons.gear},
  ];

  ProfileMenu({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    DialogInfo(
      headerText: "Quit KittyParty?",
      subText: "Are you sure you want to quit?",
      confirmText: "Confirm",
      onCancel: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
      onConfirm: () async {
        Navigator.of(context, rootNavigator: true).pop();

        DialogLoading(subtext: "Logging out...").build(context);

        final userProvider = context.read<UserProvider>();
        await userProvider.logout();

        if (!context.mounted) return;

        Navigator.of(context, rootNavigator: true).pop(); // close loading
        Navigator.pushNamedAndRemoveUntil(context, "/auth", (route) => false);
      },
    ).build(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      color: Colors.white,
      width: double.infinity,
      child: Column(
        children: menuItems.map((item) {
          return InkWell(
            onTap: () async {
              if (item['label'] == "Setting") {
                await _handleLogout(context);
              } else {
                debugPrint("${item['label']} tapped");
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 1, color: Color(0xFFEEEEEE)),
                ),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: FaIcon(
                      item['icon'],
                      size: 22,
                      color: Colors.grey[700],
                    ),
                  ),
                  Text(
                    item['label'],
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
