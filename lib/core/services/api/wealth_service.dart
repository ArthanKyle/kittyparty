import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../../../features/landing/model/wealth.dart'; // WealthStatus

class WealthService {
  final String baseUrl;

  WealthService({String? baseUrl})
      : baseUrl = (baseUrl ?? (dotenv.env['BASE_URL'] ?? ''))
      .trim()
      .replaceAll(RegExp(r'\/+$'), ''); // remove trailing /

  Future<WealthStatus> fetchMe({required String userIdentification}) async {
    if (baseUrl.isEmpty) {
      throw Exception('BASE_URL is empty');
    }

    final uid = userIdentification.trim();
    if (uid.isEmpty) {
      throw Exception('UserIdentification is empty');
    }

    // BASE_URL is .../api
    final url =
        '$baseUrl/wealth/me?UserIdentification=${Uri.encodeComponent(uid)}';

    debugPrint('🟣 [WealthService] GET $url');

    final res = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    debugPrint('🟣 [WealthService] status=${res.statusCode}');
    debugPrint('🟣 [WealthService] headers=${res.headers}');
    debugPrint('🟣 [WealthService] body=${res.body}');

    Map<String, dynamic> bodyJson = {};
    if (res.body.isNotEmpty) {
      try {
        final decoded = jsonDecode(res.body);
        if (decoded is Map<String, dynamic>) bodyJson = decoded;
      } catch (_) {
        // non-json response
      }
    }

    if (res.statusCode < 200 || res.statusCode >= 300) {
      final msg =
      (bodyJson['error'] ?? bodyJson['message'] ?? 'Request failed')
          .toString();
      throw Exception(msg);
    }

    return WealthStatus.fromJson(bodyJson);
  }
}
