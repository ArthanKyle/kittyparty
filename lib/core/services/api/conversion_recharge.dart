import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../../../features/wallet/model/convert.dart';

class ConversionService {
  final String baseUrl;

  ConversionService({String? baseUrl})
      : baseUrl = baseUrl ?? dotenv.env['BASE_URL']!;

  Future<ConvertModel> convertCoinsToDiamonds({
    required String userIdentification,
    required int coins,
  }) async {
    final url = Uri.parse("$baseUrl/conversion/convert");

    final payload = {
      "userIdentification": userIdentification,
      "coinsToConvert": coins,
    };

    debugPrint('[ConversionService] payload=$payload');

    final response = await http.post(
      url,
      headers: const {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );

    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['error'] ??
          "Conversion failed");
    }

    final json = jsonDecode(response.body);
    return ConvertModel.fromJson(json);
  }
}
