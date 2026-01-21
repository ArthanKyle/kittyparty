import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../../../features/landing/model/couple_ranking_entry.dart';
import '../../../features/landing/model/ranking_entry.dart';



class EventRankingService {
  final String baseUrl;

  EventRankingService({String? baseUrl})
      : baseUrl = baseUrl ?? dotenv.env['BASE_URL']!;

  Future<Map<String, dynamic>> _fetch(String token) async {
    final res = await http.get(
      Uri.parse('$baseUrl/events/compute'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to load rankings');
    }

    return json.decode(res.body)['rankings'];
  }

  /* ================= CP RANKING ================= */

  Future<List<CoupleRankingEntry>> getCoupleRanking(String token) async {
    final rankings = await _fetch(token);
    final list = rankings['couple'] ?? [];

    return list
        .map<CoupleRankingEntry>(
          (e) => CoupleRankingEntry.fromJson(e),
    )
        .toList();
  }

  /* ================= HONOR RANKING ================= */

  Future<List<RankingEntry>> getHonorWealth(String token) async {
    final rankings = await _fetch(token);
    final list = rankings['honor']?['wealth'] ?? [];

    return list
        .map<RankingEntry>(
          (e) => RankingEntry.fromJson(e),
    )
        .toList();
  }

  Future<List<RankingEntry>> getHonorCharm(String token) async {
    final rankings = await _fetch(token);
    final list = rankings['honor']?['charm'] ?? [];

    return list
        .map<RankingEntry>(
          (e) => RankingEntry.fromJson(e),
    )
        .toList();
  }

  /* ================= WEEKLY STAR ================= */

  Future<List<RankingEntry>> getWeeklyStar(String token) async {
    final rankings = await _fetch(token);
    final list = rankings['weeklyStar'] ?? [];

    return list
        .map<RankingEntry>(
          (e) => RankingEntry.fromJson(e),
    )
        .toList();
  }
}
