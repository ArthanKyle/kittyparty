import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../features/landing/model/dailyTask.dart';

class DailyTaskService {
  final String baseUrl;

  DailyTaskService({String? baseUrl})
      : baseUrl = baseUrl ?? dotenv.env['BASE_URL'] ?? '';

  Future<List<DailyTask>> fetchDailyTasks(String userIdentification) async {
    final uri = Uri.parse(
      '$baseUrl/tasks/daily?UserIdentification=$userIdentification',
    );

    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception(res.body);
    }

    final List list = jsonDecode(res.body);
    return list.map((e) => DailyTask.fromJson(e)).toList();
  }

  Future<void> signIn(String userIdentification) async {
    final res = await http.post(
      Uri.parse('$baseUrl/tasks/daily/sign-in'),
      headers: { 'Content-Type': 'application/json' },
      body: jsonEncode({
        'UserIdentification': userIdentification,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception(res.body);
    }
  }

}
