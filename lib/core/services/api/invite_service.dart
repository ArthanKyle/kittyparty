import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../utils/user_provider.dart';

class InviteService {
  final String baseUrl;

  InviteService({String? baseUrl})
      : baseUrl = baseUrl ?? dotenv.env['BASE_URL']!;

  Map<String, String> _headers(String token) => {
    "Content-Type": "application/json",
    "Authorization": "Bearer $token",
  };

  Future<int> fetchInviteEarnings({
    required String token,
  }) async {
    final url = Uri.parse("$baseUrl/invites/summary");

    final res = await http.get(url, headers: _headers(token));

    if (res.statusCode != 200) {
      throw Exception("Failed to fetch invite earnings");
    }

    final data = jsonDecode(res.body);
    return (data['earnedCoins'] ?? 0) as int;
  }
}
