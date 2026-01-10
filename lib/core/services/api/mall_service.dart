import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../features/landing/model/mall_item.dart';

class MallService {
  final String baseUrl;

  MallService({String? baseUrl})
      : baseUrl = baseUrl ?? dotenv.env['BASE_URL']!;

  Future<List<MallItem>> fetchMallItems() async {
    final response = await http.get(
      Uri.parse('$baseUrl/mall/items'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }

    final List data = jsonDecode(response.body);
    return data.map((e) => MallItem.fromJson(e)).toList();
  }

  Future<void> buyItem({
    required String itemId,
    required String userIdentification,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/purchases/buy'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'itemId': itemId,
        'UserIdentification': userIdentification, // ✅ REQUIRED
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
  }

  Future<void> giftItem({
    required String itemId,
    required String targetUserIdentification,
    required String userIdentification,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/purchases/gift'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'itemId': itemId,
        'targetUserIdentification': targetUserIdentification,
        'UserIdentification': userIdentification, // ✅ REQUIRED
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
  }
}
