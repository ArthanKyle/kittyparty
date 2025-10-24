import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../../../app.dart';
import '../../../../core/utils/user_provider.dart';


class ProfileMenu extends StatelessWidget {
  ProfileMenu({super.key});

  final List<Map<String, dynamic>> menuItems = [
    {
      'label': 'My Room',
      'icon': FontAwesomeIcons.house,
      'route': AppRoutes.room,
    },
    {
      'label': 'Agency',
      'icon': FontAwesomeIcons.shield,
      'route': '/agency',
    },
    {
      'label': 'My Collection',
      'icon': FontAwesomeIcons.star,
      'route': AppRoutes.collection,
    },
    {
      'label': 'Daily Tasks',
      'icon': FontAwesomeIcons.calendar,
      'route': '/tasks',
    },
    {
      'label': 'My Medals',
      'icon': FontAwesomeIcons.medal,
      'route': '/medals',
    },
    {
      'label': 'Invite',
      'icon': FontAwesomeIcons.userPlus,
      'route': '/invite',
    },
    {
      'label': 'My Level',
      'icon': FontAwesomeIcons.arrowTrendUp,
      'route': AppRoutes.level,
    },
    {
      'label': 'Mall',
      'icon': FontAwesomeIcons.shirt,
      'route': AppRoutes.mall,
    },
    {
      'label': 'My Item',
      'icon': FontAwesomeIcons.cube,
      'route': AppRoutes.item,
    },
    {
      'label': 'Setting',
      'icon': FontAwesomeIcons.gear,
      'route': AppRoutes.setting, // Navigate to SettingPage
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
            onTap: () {
              Navigator.pushNamed(context, item['route']);
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
                      color: Colors.grey.shade700,
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
