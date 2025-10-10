import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../features/landing/model/room.dart';

class RoomService {
  final String baseUrl;

  RoomService({String? baseUrl})
      : baseUrl = baseUrl ?? dotenv.env['BASE_URL']!;

  /// Create a new room for a user
  Future<Room?> createRoomForUser({
    required String userId,
    required String roomName,
  }) async {
    print(
        "[RoomService] Creating room for userId: $userId with name: $roomName");

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/rooms/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "HostID": userId,
          "RoomName": roomName,
        }),
      );

      print("[RoomService] Response status: ${response
          .statusCode}, body: ${response.body}");

      if (response.statusCode == 201) {
        final room = Room.fromJson(jsonDecode(response.body));
        print("[RoomService] Room created successfully: ${room.roomName}");
        return room;
      } else {
        print("[RoomService] Failed to create room, status: ${response
            .statusCode}");
        return null;
      }
    } catch (e) {
      print("[RoomService] Exception creating room: $e");
      return null;
    }
  }

  /// Get all rooms
  Future<List<Room>> getAllRooms() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/rooms/all'));
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((e) => Room.fromJson(e)).toList();
      } else {
        print("[RoomService] Failed to fetch all rooms, status: ${response
            .statusCode}");
      }
    } catch (e) {
      print("[RoomService] Exception fetching all rooms: $e");
    }
    return [];
  }

  /// Fetch rooms by host (Mine tab)
  Future<List<Room>> getRoomsByHostId(String hostId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/rooms/host/$hostId'));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((e) => Room.fromJson(e)).toList();
      } else {
        print("[RoomService] Failed to fetch rooms for host, status: ${response
            .statusCode}");
        print("[RoomService] Body: ${response.body}");
      }
    } catch (e) {
      print("[RoomService] Exception fetching rooms by host: $e");
    }
    return [];
  }

  /// Get a single room by ID
  Future<Room?> getRoomById(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/rooms/$id'));
      if (response.statusCode == 200) {
        return Room.fromJson(jsonDecode(response.body));
      } else {
        print("[RoomService] Failed to fetch room by ID, status: ${response
            .statusCode}");
      }
    } catch (e) {
      print("[RoomService] Exception fetching room by ID: $e");
    }
    return null;
  }

  /// Update a room
  Future<Room?> updateRoom(String id, Map<String, dynamic> updateFields) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/rooms/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updateFields),
      );
      if (response.statusCode == 200) {
        return Room.fromJson(jsonDecode(response.body));
      } else {
        print("[RoomService] Failed to update room, status: ${response
            .statusCode}");
      }
    } catch (e) {
      print("[RoomService] Exception updating room: $e");
    }
    return null;
  }

  // Inside RoomService
  /// Join a room as a participant
  Future<bool> joinRoom(String roomId, String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/rooms/$roomId/join'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"UserIdentification": userId}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("[RoomService] Exception joining room: $e");
      return false;
    }
  }

  /// Leave a room (audience)
  Future<bool> leaveRoom(String id, String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/rooms/$id/leave'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"UserIdentification": userId}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("[RoomService] Exception leaving room: $e");
      return false;
    }
  }

  /// End a room (host only)
  Future<bool> endRoom(String id, String hostId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/rooms/$id/end'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"HostID": hostId}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("[RoomService] Exception ending room: $e");
      return false;
    }
  }
}