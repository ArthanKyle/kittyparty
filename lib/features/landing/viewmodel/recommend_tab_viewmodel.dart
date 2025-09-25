// recommend_viewmodel.dart
import 'package:flutter/foundation.dart';
import 'package:kittyparty/core/services/api/room_service.dart';
import '../model/room.dart';


class RecommendViewModel extends ChangeNotifier {
  final RoomService _roomService;
  List<Room> _rooms = [];
  bool _isLoading = false;

  RecommendViewModel(this._roomService);

  List<Room> get rooms => _rooms;
  bool get isLoading => _isLoading;

  Future<void> fetchRooms(String? excludeHostId) async {
    _isLoading = true;
    notifyListeners();

    final result = await _roomService.getAllRooms();
    _rooms = excludeHostId != null
        ? result.where((r) => r.hostId != excludeHostId).toList()
        : result;

    _isLoading = false;
    notifyListeners();
  }
}
