import 'dart:convert';
import 'package:http/http.dart' as http;

class ConversionService {
  final String baseUrl;

  ConversionService({required this.baseUrl});

  // Convert coins into diamonds
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
        "coins": coins,
      }),
    );

    return jsonDecode(response.body);
  }
}
