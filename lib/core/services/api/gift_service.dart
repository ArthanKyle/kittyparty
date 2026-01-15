import 'dart:convert';
import 'package:flutter/cupertino.dart';
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
    final uri = Uri.parse('$baseUrl/gifts/send');

    final res = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'room_id': roomId,
        'sender_id': senderId,
        'receiver_id': receiverId,
        'gift_type': giftType,
        'gift_count': giftCount,
      }),
    );

    debugPrint("🌐 sendGift STATUS => ${res.statusCode}");
    debugPrint("🌐 sendGift URL => $uri");
    debugPrint("🌐 sendGift RAW BODY => ${res.body}");

    // 🚫 HARD STOP IF NOT JSON
    if (res.statusCode != 200 || !res.body.trim().startsWith('{')) {
      throw Exception("sendGift returned non-JSON response");
    }

    return jsonDecode(res.body);
  }
}
