import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../features/landing/model/userInventory.dart';

class ItemService {
  final String baseUrl;

  ItemService({String? baseUrl})
      : baseUrl = baseUrl ?? dotenv.env['BASE_URL']!;

  /// GET /api/inventory?UserIdentification=46634
  Future<List<UserInventoryItem>> fetchInventory({
    required String userIdentification,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/items?UserIdentification=$userIdentification',
    );

    final res = await http.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    if (res.statusCode != 200) {
      throw Exception(res.body);
    }

    final List data = jsonDecode(res.body);
    return data.map((e) => UserInventoryItem.fromJson(e)).toList();
  }

  /// POST /api/inventory/equip
  Future<void> equipItem({
    required String inventoryId,
    required String userIdentification,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/items/equip'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'inventoryId': inventoryId,
        'UserIdentification': userIdentification,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception(res.body);
    }
  }

  /// POST /api/inventory/unequip
  Future<void> unequipItem({
    required String inventoryId,
    required String userIdentification,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/items/unequip'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'inventoryId': inventoryId,
        'UserIdentification': userIdentification,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception(res.body);
    }
  }
}
