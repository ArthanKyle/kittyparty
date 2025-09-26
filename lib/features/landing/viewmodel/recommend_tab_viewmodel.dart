// recommend_viewmodel.dart
import 'package:flutter/foundation.dart';
import 'package:kittyparty/core/services/api/room_service.dart';
import '../model/room.dart';


class RecommendViewModel extends ChangeNotifier {
  final RoomService _roomService;
  List<Room> _rooms = [];
  bool _isLoading = false;

  bool _disposed = false;

  RecommendViewModel(this._roomService);

  List<Room> get rooms => _rooms;
  bool get isLoading => _isLoading;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void safeNotify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> fetchRooms(String? excludeHostId) async {
    _isLoading = true;
    safeNotify();

    final result = await _roomService.getAllRooms();
    if (_disposed) return;

    _rooms = excludeHostId != null
        ? result.where((r) => r.hostId != excludeHostId).toList()
        : result;

    _isLoading = false;
    safeNotify();
  }
}

