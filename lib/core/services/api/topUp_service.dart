import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/utils/user_provider.dart';

class TopUpService {
  final String baseUrl;

  TopUpService({required this.baseUrl});

  /// Create a new top-up transaction
  Future<Map<String, dynamic>?> createTopUp({
    required String userId,
    String? providerId,
    required double amount,
    required int coinsCredited,
  }) async {
    final uri = Uri.parse('$baseUrl/topups');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'providerId': providerId,
        'amount': amount,
        'coinsCredited': coinsCredited,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      print("TopUpService Error: ${response.statusCode} - ${response.body}");
      return null;
    }
  }

  /// Fetch all top-ups
  Future<List<Map<String, dynamic>>> getTopUps() async {
    final uri = Uri.parse('$baseUrl/topups');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    }
    return [];
  }

  /// Fetch a top-up by ID
  Future<Map<String, dynamic>?> getTopUpById(String id) async {
    final uri = Uri.parse('$baseUrl/topups/$id');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }
}
