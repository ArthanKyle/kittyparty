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
    final url = Uri.parse("$baseUrl/gifts/send");

    final res = await http.post(
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

    // ✅ ALWAYS try to decode JSON
    final dynamic decoded;
    try {
      decoded = jsonDecode(res.body);
    } catch (_) {
      throw Exception("sendGift: invalid JSON response");
    }

    // ✅ Return backend error cleanly
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    throw Exception("sendGift: unexpected response format");
  }

  Future<Map<String, dynamic>> fetchGifts() async {
    final url = Uri.parse("$baseUrl/gifts");

    final res = await http.get(
      url,
      headers: const {
        "Content-Type": "application/json",
      },
    );

    debugPrint("[fetchGifts] status=${res.statusCode}");
    debugPrint("[fetchGifts] body=${res.body}");

    if (res.statusCode != 200) {
      throw Exception("fetchGifts failed: ${res.statusCode}");
    }

    final decoded = jsonDecode(res.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception("fetchGifts invalid JSON shape");
    }

    if (!decoded.containsKey("data")) {
      throw Exception("fetchGifts missing 'data' key");
    }

    return decoded;
  }
}