import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/services/api/room_service.dart';
import '../../../core/utils/user_provider.dart';
import '../model/room.dart';

class LandingViewModel extends ChangeNotifier {
  final RoomService _roomService = RoomService();

  List<Room> _myRooms = [];
  List<Room> get myRooms => _myRooms;

  bool _isCreating = false;
  bool get isCreating => _isCreating;

  /// Create a room
  Future<Room?> createRoomForUser(UserProvider userProvider, String roomName) async {
    final user = userProvider.currentUser;
    if (user == null) return null;

    _isCreating = true;
    notifyListeners();

    try {
      final room = await _roomService.createRoomForUser(userId: user.userIdentification, roomName: roomName);
      if (room != null) {
        _myRooms = [room];
        notifyListeners();
      }
      return room;
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }

  /// Fetch host rooms (Mine tab)
  Future<void> fetchMyRooms(UserProvider userProvider) async {
    final user = userProvider.currentUser;
    if (user == null) return;

    try {
      _myRooms = await _roomService.getRoomsByHostId(user.userIdentification);
      notifyListeners();
    } catch (e) {
      print("[LandingViewModel] Exception fetching my rooms: $e");
    }
  }
}
