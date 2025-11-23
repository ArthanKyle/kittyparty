import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GiftService {
  final String baseUrl;

  GiftService({String? baseUrl})
      : baseUrl = baseUrl ?? dotenv.env["BASE_URL"]!;

  /// Send Gift API
  Future<Map<String, dynamic>> sendGift({
    required String token,
    required String roomId,
    required String senderId,
    required String receiverId,
    required String giftType,
    int giftCount = 1,
  }) async {
    final url = Uri.parse("$baseUrl/gifts/send");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "room_id": roomId,
        "sender_id": senderId,
        "receiver_id": receiverId,
        "gift_type": giftType,
        "gift_count": giftCount,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      return {
        "success": false,
        "message": data["error"] ?? data["message"] ?? "Unknown error"
      };
    }

    return {
      "success": true,
      "message": data["message"],
      "senderBalance": data["data"]["senderBalance"],
      "receiverBalance": data["data"]["receiverBalance"],
      "giftName": data["data"]["giftName"],
      "giftCount": data["data"]["giftCount"],
    };
  }
}
