import 'package:flutter/foundation.dart';
import '../../../core/services/api/dailyTask_service.dart';
import '../model/dailyTask.dart';

class DailyTaskViewModel extends ChangeNotifier {
  final DailyTaskService _service;

  DailyTaskViewModel(this._service);

  List<DailyTask> dailyTasks = [];
  bool isLoading = false;
  bool isSigningIn = false;
  bool isClaiming = false;

  /// ✅ derived state
  bool get signedInToday {
    final t = dailyTasks.where((e) => e.key == 'sign_in');
    if (t.isEmpty) return false;
    final task = t.first;
    return task.completed || task.rewarded || task.progress >= 1;
  }

  /// ✅ THIS WAS MISSING
  double get todayProgressRatio {
    if (dailyTasks.isEmpty) return 0.0;

    int totalTarget = 0;
    int totalProgress = 0;

    for (final t in dailyTasks) {
      final target = t.target <= 0 ? 1 : t.target;
      final progress = t.progress.clamp(0, target);

      totalTarget += target;
      totalProgress += progress;
    }

    if (totalTarget == 0) return 0.0;
    return (totalProgress / totalTarget).clamp(0.0, 1.0);
  }

  Future<void> claim(String userIdentification, String taskKey) async {
    final uid = userIdentification.trim();

    debugPrint('🔄 [DailyTaskVM] claim uid=$uid taskKey=$taskKey');

    isClaiming = true;
    notifyListeners();

    try {
      await _service.claimReward(uid, taskKey);
      await fetchDailyTasks(uid);
    } finally {
      isClaiming = false;
      notifyListeners();
    }
  }

  Future<void> fetchDailyTasks(String userIdentification) async {
    final uid = userIdentification.trim();

    isLoading = true;
    notifyListeners();

    try {
      dailyTasks = await _service.fetchDailyTasks(uid);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signIn(String userIdentification) async {
    if (signedInToday) return;

    isSigningIn = true;
    notifyListeners();

    try {
      await _service.signIn(userIdentification.trim());
      await fetchDailyTasks(userIdentification);
    } finally {
      isSigningIn = false;
      notifyListeners();
    }
  }
}
