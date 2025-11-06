import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ConversionService {
  final String baseUrl;

  ConversionService({String? baseUrl})
      : baseUrl = baseUrl ?? dotenv.env['BASE_URL']!;

  Future<Map<String, dynamic>> convertCoinsToDiamonds({
    required String userId,
    required int coins,
  }) async {
    final url = Uri.parse("$baseUrl/conversion/convert");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userId": userId,
        "coinsToConvert": coins,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Conversion failed: ${response.body}");
    }

    return jsonDecode(response.body);
  }
}
