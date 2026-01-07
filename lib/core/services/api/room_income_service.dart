import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RoomIncomeService {
  final String baseUrl;
  RoomIncomeService({String? baseUrl})
      : baseUrl = baseUrl ?? dotenv.env['BASE_URL']!;

  Future<bool> recordGiftContribution({
    required String roomId,
    required int amountCoins,
    required String senderId,
    required String receiverId,
    required String giftId,
    required String giftName,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/rooms/$roomId/income'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "eventType": "gift_sent",
        "amountCoins": amountCoins,
        "senderId": senderId,
        "receiverId": receiverId,
        "meta": {
          "giftId": giftId,
          "giftName": giftName,
        }
      }),
    );
    return res.statusCode == 201;
  }

  Future<Map<String, dynamic>?> getSummary(String roomId) async {
    final res = await http.get(Uri.parse('$baseUrl/rooms/$roomId/income/summary'));
    if (res.statusCode != 200) return null;
    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}
