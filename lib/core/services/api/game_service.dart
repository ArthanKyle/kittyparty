import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GameService {
  final String baseUrl;

  GameService({String? baseUrl})
      : baseUrl = baseUrl ?? dotenv.env['BASE_URL'] ?? '';

  Future<List<Map<String, dynamic>>> fetchGames(String userId) async {
    if (baseUrl.isEmpty) {
      throw Exception('BASE_URL is not defined in .env');
    }

    final uri = Uri.parse('$baseUrl/games?userId=$userId');
    final response = await http.get(uri);

    print('🌍 [GameService] GET $uri');
    print('📦 [Response Code] ${response.statusCode}');
    print('📜 [Response Body] ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['code'] == 0 && data['data'] != null) {
        final List<Map<String, dynamic>> games =
        List<Map<String, dynamic>>.from(data['data']);

        // 🔹 Clean and format each name nicely
        final formattedGames = games.map((game) {
          final rawName = (game['name'] ?? '').toString();

          // ✅ Replace underscores with spaces and capitalize each word properly
          final readableName = rawName
              .replaceAll('_', ' ') // "color_game" → "color game"
              .replaceAllMapped(
            RegExp(r'(^\w)|(\s\w)'), // capitalizes first letter of each word
                (Match m) => m.group(0)!.toUpperCase(),
          );

          return {
            ...game,
            'name': readableName,
          };
        }).toList();

        print('✅ [Formatted Games] ${formattedGames.map((g) => g['name']).toList()}');
        return formattedGames;
      }

      throw Exception('Backend error: ${data['msg'] ?? 'Unknown backend error'}');
    } else {
      throw Exception(
          'HTTP ${response.statusCode}: Failed to fetch games — ${response.body}');
    }
  }
}
