import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../../../core/global_widgets/dialogs/dialog_info.dart';
import '../../../../core/global_widgets/dialogs/dialog_loading.dart';
import '../../../../core/utils/user_provider.dart';


class ProfileMenu extends StatelessWidget {
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

        Navigator.of(context, rootNavigator: true).pop();
        Navigator.pushNamedAndRemoveUntil(context, "/auth", (route) => false);
      },
    ).build(context);
  }

  late final List<Map<String, dynamic>> menuItems = [
    {
      'label': 'My Room',
      'icon': FontAwesomeIcons.house,
      'onTap': (BuildContext context) {
        Navigator.pushNamed(context, '/room');
      },
    },
    {
      'label': 'Agency',
      'icon': FontAwesomeIcons.shield,
      'onTap': (BuildContext context) {
        Navigator.pushNamed(context, '/agency');
      },
    },
    {
      'label': 'My Collection',
      'icon': FontAwesomeIcons.star,
      'onTap': (BuildContext context) {
        Navigator.pushNamed(context, '/collection');
      },
    },
    {
      'label': 'Daily Tasks',
      'icon': FontAwesomeIcons.calendar,
      'onTap': (BuildContext context) {
        Navigator.pushNamed(context, '/tasks');
      },
    },
    {
      'label': 'My Medals',
      'icon': FontAwesomeIcons.medal,
      'onTap': (BuildContext context) {
        Navigator.pushNamed(context, '/medals');
      },
    },
    {
      'label': 'Invite',
      'icon': FontAwesomeIcons.userPlus,
      'onTap': (BuildContext context) {
        Navigator.pushNamed(context, '/invite');
      },
    },
    {
      'label': 'My Level',
      'icon': FontAwesomeIcons.arrowTrendUp,
      'onTap': (BuildContext context) {
        Navigator.pushNamed(context, '/level');
      },
    },
    {
      'label': 'Mall',
      'icon': FontAwesomeIcons.shirt,
      'onTap': (BuildContext context) {
        Navigator.pushNamed(context, '/mall');
      },
    },
    {
      'label': 'My Item',
      'icon': FontAwesomeIcons.cube,
      'onTap': (BuildContext context) {
        Navigator.pushNamed(context, '/items');
      },
    },
    {
      'label': 'Setting',
      'icon': FontAwesomeIcons.gear,
      'onTap': (BuildContext context) {
        Navigator.pushNamed(context, '/setting');
      },
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      color: Colors.white,
      width: double.infinity,
      child: Column(
        children: menuItems.map((item) {
          return InkWell(
            onTap: () => item['onTap'](context),
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
