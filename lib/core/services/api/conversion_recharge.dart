import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../../../features/wallet/model/convert.dart';

class ConversionService {
  final String baseUrl;

  ConversionService({String? baseUrl})
      : baseUrl = baseUrl ?? dotenv.env['BASE_URL']!;

  /// Diamonds → Coins (VERY LOW RETURN)
  /// Rule: 130 diamonds = 1 coin
  Future<ConvertModel> convertDiamondsToCoins({
    required String userIdentification,
    required int diamonds,
  }) async {
    final url =
    Uri.parse("$baseUrl/conversion/convert");

    final payload = {
      "userIdentification": userIdentification,
      "diamondsToConvert": diamonds,
    };

    debugPrint('[ConversionService][D2C] payload=$payload');

    final response = await http.post(
      url,
      headers: const {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );

    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);
      throw Exception(body['error'] ?? "Diamond exchange failed");
    }

    final json = jsonDecode(response.body);
    return ConvertModel.fromJson(json);
  }
}
