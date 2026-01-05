import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../features/landing/model/dailyTask.dart';

class DailyTaskService {
  final String baseUrl;

  DailyTaskService({String? baseUrl})
      : baseUrl = baseUrl ?? (dotenv.env['BASE_URL'] ?? '');

  Future<List<DailyTask>> fetchDailyTasks(String userIdentification) async {
    final uri = Uri.parse('$baseUrl/tasks/daily')
        .replace(queryParameters: {'UserIdentification': userIdentification});

    debugPrint('🌐 [DailyTaskService] GET $uri');

    final res = await http.get(uri);

    debugPrint('📩 [DailyTaskService] status=${res.statusCode} body=${res.body}');

    if (res.statusCode != 200) {
      throw Exception(res.body);
    }

    final List list = jsonDecode(res.body) as List;
    return list.map((e) => DailyTask.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> signIn(String userIdentification) async {
    final uri = Uri.parse('$baseUrl/tasks/daily/sign-in');

    debugPrint('🌐 [DailyTaskService] POST $uri');
    debugPrint('📤 [DailyTaskService] body={"UserIdentification":"$userIdentification"}');

    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'UserIdentification': userIdentification}),
    );

    debugPrint('📩 [DailyTaskService] status=${res.statusCode} body=${res.body}');

    if (res.statusCode != 200) {
      throw Exception(res.body);
    }
  }
}
