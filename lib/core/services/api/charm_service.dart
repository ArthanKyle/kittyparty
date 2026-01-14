import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../features/landing/model/wealth.dart';

class CharmService {
  final String baseUrl;

  CharmService({String? baseUrl})
      : baseUrl = baseUrl ?? dotenv.env['BASE_URL']!;

  /* =========================
   * GET /api/charm/me
   * ========================= */
  Future<WealthStatus> fetchCharmStatus({
    required String userIdentification,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/charms/me?UserIdentification=$userIdentification',
    );

    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception('Failed to load charm status');
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    return WealthStatus.fromJson(json);
  }
}
