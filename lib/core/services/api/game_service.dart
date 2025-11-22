import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GameService {
  final String baseUrl;

  GameService({String? baseUrl})
      : baseUrl = baseUrl ?? dotenv.env['BASE_URL'] ?? '';

  void _printRawResponse(String tag, http.Response res, {bool pretty = true}) {
    print("[$tag] Status: ${res.statusCode}");
    try {
      final decoded = jsonDecode(res.body);
      print(
        "[$tag] Body: ${pretty ? JsonEncoder.withIndent('  ').convert(decoded) : res.body}",
      );
    } catch (_) {
      print("[$tag] Body (raw): ${res.body}");
    }
  }

  Future<List<Map<String, dynamic>>> fetchGames(String userId) async {
    if (baseUrl.isEmpty) {
      throw Exception('BASE_URL is not defined in .env');
    }

    final uri = Uri.parse('$baseUrl/games');
    final response = await http.get(uri);

    // 🔥 print the raw response
    _printRawResponse("GET /games", response);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['code'] == 0 && data['data'] != null) {
        final List<Map<String, dynamic>> games =
        List<Map<String, dynamic>>.from(data['data']);

        final formattedGames = games.map((game) {
          final rawName = (game['name'] ?? '').toString();

          final readableName = rawName
              .replaceAll('_', ' ')
              .replaceAllMapped(
            RegExp(r'(^\w)|(\s\w)'),
                (Match m) => m.group(0)!.toUpperCase(),
          );

          return {...game, 'name': readableName};
        }).toList();

        return formattedGames;
      }

      throw Exception('Backend error: ${data['msg'] ?? 'Unknown backend error'}');
    } else {
      throw Exception(
          'HTTP ${response.statusCode}: Failed to fetch games — ${response.body}');
    }
  }
}
