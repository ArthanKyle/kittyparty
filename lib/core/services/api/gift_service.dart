import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GiftService {
  final String baseUrl = dotenv.env["BASE_URL"]!;

  Future<Map<String, dynamic>> sendGift({
    required String token,
    required String roomId,
    required String senderId,
    required String receiverId,
    required String giftType,
    required int giftCount,
  }) async {

    final url = Uri.parse("$baseUrl/gifts/send");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: jsonEncode({
        "room_id": roomId,
        "sender_id": senderId,
        "receiver_id": receiverId,
        "gift_type": giftType,
        "gift_count": giftCount
      }),
    );

    final json = jsonDecode(response.body);

    if (response.statusCode != 200 || json["success"] != true) {
      return {
        "success": false,
        "message": json["message"] ?? "Unknown error",
      };
    }

    return {
      "success": true,
      "giftName": json["giftName"],       // <-- SVGA file match
      "displayName": json["displayName"], // <-- UI name
      "price": json["price"],
      "count": json["count"],
    };
  }
}
