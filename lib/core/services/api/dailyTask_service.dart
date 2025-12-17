import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../features/landing/model/dailyTask.dart';

class DailyTaskService {
  final String baseUrl;

  DailyTaskService({String? baseUrl})
      : baseUrl = baseUrl ?? dotenv.env['BASE_URL'] ?? '';

  Future<List<DailyTask>> fetchDailyTasks(String token) async {
    final res = await http.get(
      Uri.parse('$baseUrl/tasks/daily'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    final decoded = jsonDecode(res.body);

    if (decoded is List) {
      return decoded
          .map((e) => DailyTask.fromJson(e))
          .toList();
    }

    if (decoded is Map && decoded['data'] is List) {
      // Backend returns wrapped array
      return (decoded['data'] as List)
          .map((e) => DailyTask.fromJson(e))
          .toList();
    }

    // Fallback — backend returned no tasks or error
    return [];
  }

  Future<void> signIn(String token) async {
    await http.post(
      Uri.parse('$baseUrl/tasks/daily/sign-in'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
  }
}
