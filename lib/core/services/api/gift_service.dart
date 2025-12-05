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

    final jsonRes = jsonDecode(response.body);

    // Failure case
    if (response.statusCode != 200 || jsonRes["success"] != true) {
      return {
        "success": false,
        "message": jsonRes["message"] ?? "Gift failed",
      };
    }

    // Success case
    return {
      "success": true,
      "giftName": jsonRes["giftName"],     // used for SVGA animation
      "giftID": jsonRes["giftID"],
      "price": jsonRes["price"],
      "count": jsonRes["count"],
      "totalCost": jsonRes["totalCost"],
      "senderBalance": jsonRes["senderBalance"],
    };
  }
}
