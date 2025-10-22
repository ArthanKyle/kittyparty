import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GameService {
  final String baseUrl;


  GameService({String? baseUrl})
      : baseUrl = baseUrl ?? dotenv.env['BASE_URL']!;

  Future<List<Map<String, dynamic>>> fetchGames({int gameListType = 3}) async {
    final url = Uri.parse('$baseUrl/games/list');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'game_list_type': gameListType}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['code'] == 0 && data['data'] != null) {
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        throw Exception('Backend error: ${data['message'] ?? 'Unknown error'}');
      }
    } else {
      throw Exception('HTTP ${response.statusCode}: Failed to fetch games');
    }
  }
}
