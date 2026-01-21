import 'package:flutter/material.dart';

import '../../../core/services/api/event_ranking_service.dart';
import '../model/couple_ranking_entry.dart';
import '../model/ranking_entry.dart';

class EventRankingViewModel extends ChangeNotifier {
  // ✅ SAME PATTERN AS RoomService, WalletService, etc.
  final EventRankingService _service = EventRankingService();

  bool loading = false;
  String? error;

  List<CoupleRankingEntry> couple = [];
  List<RankingEntry> honorWealth = [];
  List<RankingEntry> honorCharm = [];
  List<RankingEntry> weeklyStar = [];

  /* ================= LOAD ALL ================= */

  Future<void> loadAll(String token) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _service.getCoupleRanking(token),
        _service.getHonorWealth(token),
        _service.getHonorCharm(token),
        _service.getWeeklyStar(token),
      ]);

      couple = results[0] as List<CoupleRankingEntry>;
      honorWealth = results[1] as List<RankingEntry>;
      honorCharm = results[2] as List<RankingEntry>;
      weeklyStar = results[3] as List<RankingEntry>;
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /* ================= PARTIAL LOADS ================= */

  Future<void> loadCouple(String token) async {
    loading = true;
    notifyListeners();

    try {
      couple = await _service.getCoupleRanking(token);
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> loadHonorWealth(String token) async {
    loading = true;
    notifyListeners();

    try {
      honorWealth = await _service.getHonorWealth(token);
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> loadHonorCharm(String token) async {
    loading = true;
    notifyListeners();

    try {
      honorCharm = await _service.getHonorCharm(token);
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> loadWeeklyStar(String token) async {
    loading = true;
    notifyListeners();

    try {
      weeklyStar = await _service.getWeeklyStar(token);
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /* ================= HELPERS ================= */

  bool get hasCouple => couple.isNotEmpty;
  bool get hasHonor =>
      honorWealth.isNotEmpty || honorCharm.isNotEmpty;
  bool get hasWeeklyStar => weeklyStar.isNotEmpty;

  void clearError() {
    error = null;
    notifyListeners();
  }
}
