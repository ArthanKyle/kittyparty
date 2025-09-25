import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class RechargeService {
  final String baseUrl;

  RechargeService({String? baseUrl})
      : baseUrl = baseUrl ?? dotenv.env['BASE_URL']!;

  /// Create Stripe Payment Intent
  Future<Map<String, dynamic>?> createPaymentIntent({
    required int amount,
    required String countryCode,
    required String currency,
    required String userId, // pass the actual logged-in user ID
  }) async {
    final url = Uri.parse("$baseUrl/payments/create-payment-intent");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "amount": amount,
        "currency": currency,
        "countryCode": countryCode,
        "userId": userId, // must be logged-in user ID
      }),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return {
        "clientSecret": body["clientSecret"],
        "paymentId": body["paymentId"],
      };
    } else {
      print("RechargeService Error: ${response.body}");
      return null;
    }
  }

  /// Get all payments for a user
  Future<List<dynamic>> getUserPayments(String userId) async {
    final url = Uri.parse("$baseUrl/payments/user/$userId");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("RechargeService Error: ${response.body}");
      return [];
    }
  }
}
