import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../features/wallet/model/recharge.dart';
import '../../../features/wallet/model/transaction.dart';

class RechargeService {
  final String baseUrl;

  // Use env fallback if no baseUrl provided
  RechargeService({String? baseUrl})
      : baseUrl = baseUrl ?? dotenv.env['BASE_URL']!;

  // 🔹 Step 1: Create PaymentIntent
  Future<Map<String, dynamic>> createPaymentIntent({
    required String userId,
    required double amount,
    required String countryCode,
    String? method,
  }) async {
    final url = Uri.parse("$baseUrl/recharge/create-payment-intent");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userId": userId,
        "amount": amount,
        "countryCode": countryCode,
        "method": method ?? "card",
      }),
    );

    final data = jsonDecode(response.body);
    return data;
  }

  // 🔹 Step 2: Confirm Payment & credit coins
  Future<TransactionModel> confirmPayment({required String transactionId}) async {
    final url = Uri.parse("$baseUrl/recharge/confirm-payment");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"transactionId": transactionId}),
    );

    final data = jsonDecode(response.body);
    if (!data['success']) {
      throw Exception(data['error'] ?? "Payment recording failed");
    }

    return TransactionModel.fromJson(data['topUp']);
  }


  // 🔹 Step 3: Admin - all payments
  Future<List<TransactionModel>> getAllPayments() async {
    final url = Uri.parse("$baseUrl/recharge/all-payments");
    final response = await http.get(url);
    final List jsonList = jsonDecode(response.body);
    return jsonList.map((e) => TransactionModel.fromJson(e)).toList();
  }

  // 🔹 Step 4: Admin - all top-ups
  Future<List<TransactionModel>> getAllTopUps() async {
    final url = Uri.parse("$baseUrl/recharge/all-top-ups");
    final response = await http.get(url);
    final List jsonList = jsonDecode(response.body);
    return jsonList.map((e) => TransactionModel.fromJson(e)).toList();
  }

  // 🔹 Step 5: User history
  Future<List<TransactionModel>> getUserHistory(String userId) async {
    final url = Uri.parse("$baseUrl/recharge/user-history/$userId");
    final response = await http.get(url);
    final List jsonList = jsonDecode(response.body);
    return jsonList.map((e) => TransactionModel.fromJson(e)).toList();
  }

  // 🔹 Step 6: Fetch dynamic packages for user
  Future<List<RechargePackage>> fetchPackages(String userId) async {
    final url = Uri.parse("$baseUrl/package/packages?userId=$userId");
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch packages: ${response.body}");
    }

    final List data = jsonDecode(response.body);
    return data.map((pkg) => RechargePackage.fromJson(pkg)).toList();
  }
}
