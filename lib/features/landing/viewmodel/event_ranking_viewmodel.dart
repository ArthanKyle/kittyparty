import 'package:flutter/material.dart';

import '../../../core/services/api/event_ranking_service.dart';
import '../model/couple_ranking_entry.dart';
import '../model/ranking_entry.dart';


class EventRankingViewModel extends ChangeNotifier {
  final EventRankingService service;

  EventRankingViewModel(this.service);

  bool loading = false;
  String? error;

  List<CoupleRankingEntry> couple = [];
  List<RankingEntry> honorWealth = [];
  List<RankingEntry> honorCharm = [];
  List<RankingEntry> weeklyStar = [];

  Future<void> loadAll(String token) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      couple = await service.getCoupleRanking(token);
      honorWealth = await service.getHonorWealth(token);
      honorCharm = await service.getHonorCharm(token);
      weeklyStar = await service.getWeeklyStar(token);
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  bool get hasCouple => couple.isNotEmpty;
  bool get hasHonor =>
      honorWealth.isNotEmpty || honorCharm.isNotEmpty;
  bool get hasWeeklyStar => weeklyStar.isNotEmpty;
}
