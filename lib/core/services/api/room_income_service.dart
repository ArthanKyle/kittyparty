import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RoomIncomeSummary {
  final int contributionTodayCoins;
  final int contributionTotalCoins;
  final int dailyRewardTierPaid;
  final DateTime? lastResetAt;

  RoomIncomeSummary({
    required this.contributionTodayCoins,
    required this.contributionTotalCoins,
    required this.dailyRewardTierPaid,
    required this.lastResetAt,
  });

  factory RoomIncomeSummary.fromJson(Map<String, dynamic> json) {
    final lastResetRaw = json['lastResetAt'];
    DateTime? lastReset;
    if (lastResetRaw is String && lastResetRaw.isNotEmpty) {
      lastReset = DateTime.tryParse(lastResetRaw);
    }

    int toInt(dynamic v) {
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    return RoomIncomeSummary(
      contributionTodayCoins: toInt(json['contributionTodayCoins']),
      contributionTotalCoins: toInt(json['contributionTotalCoins']),
      dailyRewardTierPaid: toInt(json['dailyRewardTierPaid']),
      lastResetAt: lastReset,
    );
  }
}

class RoomIncomeService {
  final String baseUrl;

  RoomIncomeService({String? baseUrl})
      : baseUrl = baseUrl ?? dotenv.env['BASE_URL']!;

  String get socketUrl {
    var u = baseUrl;
    if (u.endsWith("/")) u = u.substring(0, u.length - 1);
    if (u.endsWith("/api")) u = u.substring(0, u.length - 4);
    return u;
  }

  Future<bool> recordIncome({
    required String roomId,
    required String eventType,
    required int amountCoins,
    String? senderId,
    String? receiverId,
    Map<String, dynamic>? meta,
    String? externalId,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/room-income/$roomId/income'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "eventType": eventType,
        "amountCoins": amountCoins,
        "senderId": senderId,
        "receiverId": receiverId,
        "meta": meta ?? {},
        "externalId": externalId,
      }),
    );

    return res.statusCode == 201 || res.statusCode == 200;
  }

  Future<RoomIncomeSummary?> getSummary(String roomId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/room-income/$roomId/income/summary'),
    );
    if (res.statusCode != 200) return null;

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    return RoomIncomeSummary.fromJson(json);
  }
}
