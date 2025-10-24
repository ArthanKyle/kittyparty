import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GameService {
  final String baseUrl;
  GameService({String? baseUrl}) : baseUrl = baseUrl ?? dotenv.env['BASE_URL']!;

  Future<List<Map<String, dynamic>>> fetchGames() async {
    final url = Uri.parse('$baseUrl/games/list');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['code'] == 0 && data['data'] != null) {
        return List<Map<String, dynamic>>.from(data['data']);
      }
      throw Exception('Backend error: ${data['message'] ?? 'Unknown error'}');
    } else {
      throw Exception('HTTP ${response.statusCode}: Failed to fetch games');
    }
  }
}
