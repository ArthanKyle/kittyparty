import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../features/landing/model/dailyTask.dart';

class DailyTaskService {
  final String baseUrl;

  DailyTaskService({String? baseUrl})
      : baseUrl = baseUrl ?? dotenv.env['BASE_URL'] ?? '';

  Future<List<DailyTask>> fetchDailyTasks(String userIdentification) async {
    final uid = userIdentification.trim();

    final uri = Uri.parse('$baseUrl/tasks/daily')
        .replace(queryParameters: {'UserIdentification': uid});

    debugPrint('📩 [DailyTaskService] GET $uri');

    final res = await http.get(uri);

    debugPrint(
      '📩 [DailyTaskService] status=${res.statusCode} body=${res.body}',
    );

    if (res.statusCode != 200) {
      throw Exception(res.body);
    }

    final decoded = jsonDecode(res.body);
    if (decoded is! List) {
      throw Exception('Invalid response format: expected List');
    }

    return decoded.map<DailyTask>((e) => DailyTask.fromJson(e)).toList();
  }

  Future<void> claimReward(String userIdentification, String taskKey) async {
    final res = await http.post(
      Uri.parse('$baseUrl/tasks/daily/claim'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'UserIdentification': userIdentification,
        'taskKey': taskKey,
      }),
    );

    debugPrint('📩 [DailyTaskService] CLAIM status=${res.statusCode} body=${res.body}');

    if (res.statusCode != 200) {
      throw Exception(res.body);
    }
  }


  Future<void> signIn(String userIdentification) async {
    final uid = userIdentification.trim();

    final uri = Uri.parse('$baseUrl/tasks/daily/sign-in');

    debugPrint('📩 [DailyTaskService] POST $uri body={UserIdentification:$uid}');

    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'UserIdentification': uid}),
    );

    debugPrint(
      '📩 [DailyTaskService] status=${res.statusCode} body=${res.body}',
    );

    if (res.statusCode != 200) {
      throw Exception(res.body);
    }
  }
}
