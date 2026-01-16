import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../features/wallet/model/recharge.dart';
import '../../../features/wallet/model/transaction.dart';

class RechargeService {
  final String baseUrl;

  RechargeService({String? baseUrl})
      : baseUrl = baseUrl ?? dotenv.env['BASE_URL']!;

  /* =============================
     STEP 1: CREATE PAYMENT INTENT
  ============================== */
  Future<Map<String, dynamic>> createPaymentIntent({
    required String userIdentification,
    required double amount,
    required String countryCode,
    String? method,
    required int coins,
  }) async {
    final url =
    Uri.parse("$baseUrl/recharge/create-payment-intent");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userIdentification": userIdentification,
        "amount": amount,
        "countryCode": countryCode,
        "method": method ?? "card",
        "coins": coins,
      }),
    );

    return jsonDecode(response.body);
  }

  /* =============================
     STEP 2: CONFIRM PAYMENT
  ============================== */
  Future<TransactionModel> confirmPayment({
    required String transactionId,
  }) async {
    final url = Uri.parse("$baseUrl/recharge/confirm-payment");

    // 🔍 LOG: request
    debugPrint("🔵 [CONFIRM PAYMENT] URL: $url");
    debugPrint("🔵 [CONFIRM PAYMENT] Payload: { transactionId: $transactionId }");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"transactionId": transactionId}),
    );

    // 🔍 LOG: raw response
    debugPrint("🟡 [CONFIRM PAYMENT] Status Code: ${response.statusCode}");
    debugPrint("🟡 [CONFIRM PAYMENT] Raw Body: ${response.body}");

    final data = jsonDecode(response.body);

    // 🔍 LOG: decoded response
    debugPrint("🟢 [CONFIRM PAYMENT] Decoded JSON: $data");

    if (data['success'] != true) {
      debugPrint("🔴 [CONFIRM PAYMENT] Error: ${data['error']}");
      throw Exception(data['error'] ?? "Payment confirmation failed");
    }

    // 🔍 LOG: success payload
    debugPrint("✅ [CONFIRM PAYMENT] TopUp Data: ${data['topUp']}");

    return TransactionModel.fromJson(data['topUp']);
  }

  /* =============================
     STEP 3: ADMIN – ALL TRANSACTIONS
  ============================== */
  Future<List<TransactionModel>> getAllTransactions() async {
    final url =
    Uri.parse("$baseUrl/recharge/all-transactions");

    final response = await http.get(url);
    final List list = jsonDecode(response.body);
    return list.map((e) => TransactionModel.fromJson(e)).toList();
  }

  /* =============================
     STEP 4: USER HISTORY
  ============================== */
  Future<List<TransactionModel>> getUserHistory(String userIdentification) async {
    final url =
    Uri.parse("$baseUrl/recharge/user-history/$userIdentification");

    final response = await http.get(url);
    final Map<String, dynamic> decoded = jsonDecode(response.body); // Decode as a map
    final List<dynamic> list = decoded['data'] ?? []; // Safely extract the data array

    return list.map((e) => TransactionModel.fromJson(e)).toList(); // Convert to list of models
  }


  /* =============================
     STEP 5: FETCH PACKAGES
  ============================== */
  Future<List<RechargePackage>> fetchPackages(
      String userIdentification,) async {
    final url = Uri.parse(
      "$baseUrl/package/packages?userIdentification=$userIdentification",
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception(
        "Failed to fetch packages: ${response.body}",
      );
    }

    final List data = jsonDecode(response.body);
    return data.map((e) => RechargePackage.fromJson(e)).toList();
  }
}
