import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../../../app.dart';
import '../../../../core/services/api/room_service.dart';
import '../../../../core/utils/user_provider.dart';
import '../../../landing/model/room.dart';

class ProfileMenu extends StatelessWidget {
  ProfileMenu({super.key});

  final List<Map<String, dynamic>> menuItems = [
    {'label': 'My Room', 'icon': FontAwesomeIcons.house, 'route': AppRoutes.room},
    {'label': 'Agency', 'icon': FontAwesomeIcons.shield, 'route': AppRoutes.agency},
    {'label': 'My Collection', 'icon': FontAwesomeIcons.star, 'route': AppRoutes.collection},
    {'label': 'Daily Tasks', 'icon': FontAwesomeIcons.calendar, 'route': AppRoutes.tasks},
    {'label': 'My Medals', 'icon': FontAwesomeIcons.medal, 'route': '/medals'},
    {'label': 'Invite', 'icon': FontAwesomeIcons.userPlus, 'route': AppRoutes.invite},
    {'label': 'My Level', 'icon': FontAwesomeIcons.arrowTrendUp, 'route': AppRoutes.level},
    {'label': 'Mall', 'icon': FontAwesomeIcons.shirt, 'route': AppRoutes.mall},
    {'label': 'My Item', 'icon': FontAwesomeIcons.cube, 'route': AppRoutes.item},
    {'label': 'Setting', 'icon': FontAwesomeIcons.gear, 'route': AppRoutes.setting},
  ];

  final RoomService _roomService = RoomService();

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Container(
      margin: const EdgeInsets.only(top: 10),
      color: Colors.white,
      width: double.infinity,
      child: Column(
        children: menuItems.map((item) {
          return InkWell(
            onTap: () => _handleMenuTap(context, item, userProvider),
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
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Future<void> _handleMenuTap(
      BuildContext context,
      Map<String, dynamic> item,
      UserProvider userProvider,
      ) async {
    final String route = item['route'];
    final user = userProvider.currentUser;

    if (route == AppRoutes.room) {
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("User not found. Please log in again."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Show loading while checking room
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Checking your room..."),
          duration: Duration(seconds: 1),
        ),
      );

      // Fetch user's room(s)
      final rooms = await _roomService.getRoomsByHostId(user.id);

      if (rooms.isNotEmpty) {
        final Room userRoom = rooms.first;

        Navigator.pushNamed(
          context,
          AppRoutes.room,
          arguments: {
            'roomId': userRoom.id,
            'hostId': user.id,
            'roomName': userRoom.roomName,
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("You don't have a room yet!"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      Navigator.pushNamed(context, route);
    }
  }
}
