import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../features/landing/model/agency_withdraw.dart';
import '../../utils/user_provider.dart';

class AgencyWithdrawService {
  static final String _baseUrl = dotenv.env['BASE_URL']!;

  static Map<String, String> _headers(UserProvider userProvider) {
    final token = userProvider.token;
    return {
      "Content-Type": "application/json",
      if (token != null && token.isNotEmpty)
        "Authorization": "Bearer $token",
    };
  }

  /* ===============================
     REQUEST WITHDRAW
  =============================== */
  static Future<void> requestWithdraw({
    required UserProvider userProvider,
    required String agencyCode,
    required int diamonds,
  }) async {
    debugPrint("🏦 [Withdraw] START");

    final agencyRes = await http.get(
      Uri.parse("$_baseUrl/agencies/$agencyCode"),
      headers: _headers(userProvider),
    );

    debugPrint("🏦 resolveAgency STATUS=${agencyRes.statusCode}");
    debugPrint("🏦 resolveAgency BODY=${agencyRes.body}");

    if (agencyRes.statusCode != 200) {
      throw Exception("Failed to resolve agency");
    }

    final decoded = jsonDecode(agencyRes.body);
    final agency = decoded["agency"];
    final agencyId = agency["id"];

    debugPrint("🏦 agencyId=$agencyId");

    if (agencyId == null) {
      throw Exception("Failed to resolve agencyId");
    }

    final res = await http.post(
      Uri.parse("$_baseUrl/agency-withdraw/agency/withdraw"),
      headers: _headers(userProvider),
      body: jsonEncode({
        "agencyId": agencyId,
        "diamonds": diamonds,
        "userIdentification": userProvider.currentUser!.userIdentification,
      }),
    );

    debugPrint("🏦 withdraw STATUS=${res.statusCode}");
    debugPrint("🏦 withdraw BODY=${res.body}");

    if (res.statusCode != 200) {
      final err = jsonDecode(res.body);
      throw Exception(err["message"] ?? "Withdraw failed");
    }

    debugPrint("🏦 [Withdraw] SUCCESS");
  }
  /* ===============================
     FETCH MY WITHDRAWALS
  =============================== */
  static Future<List<AgencyWithdrawDto>> fetchMyWithdrawals({
    required UserProvider userProvider,
  }) async {
    final res = await http.get(
      Uri.parse("$_baseUrl/agency-withdraw/agency/withdraw"),
      headers: _headers(userProvider),
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to load withdrawals");
    }

    final List data = jsonDecode(res.body);
    return data
        .map((e) => AgencyWithdrawDto.fromJson(e))
        .toList();
  }
}
