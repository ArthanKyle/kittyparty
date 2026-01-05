import 'package:flutter/material.dart';
import '../../../core/services/api/dailyTask_service.dart';
import '../model/dailyTask.dart';

class DailyTaskViewModel extends ChangeNotifier {
  final DailyTaskService _service;

  DailyTaskViewModel(this._service);

  List<DailyTask> dailyTasks = [];
  bool isLoading = false;
  String? lastError;

  Future<void> fetchDailyTasks(String userIdentification) async {
    isLoading = true;
    lastError = null;
    notifyListeners();

    debugPrint('🧾 [DailyTaskVM] fetchDailyTasks userIdentification=$userIdentification');

    try {
      final result = await _service.fetchDailyTasks(userIdentification);
      dailyTasks = result;

      debugPrint('✅ [DailyTaskVM] fetched ${dailyTasks.length} tasks');
      for (final t in dailyTasks) {
        debugPrint(
          '  - key=${t.key} progress=${t.progress}/${t.target} '
              'completed=${t.completed} rewarded=${t.rewarded}',
        );
      }
    } catch (e) {
      lastError = e.toString();
      dailyTasks = [];
      debugPrint('❌ [DailyTaskVM] fetchDailyTasks error=$lastError');
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> signIn(String userIdentification) async {
    debugPrint('🟦 [DailyTaskVM] signIn userIdentification=$userIdentification');

    try {
      await _service.signIn(userIdentification);
      debugPrint('✅ [DailyTaskVM] signIn success');

      // refresh list after signing in
      await fetchDailyTasks(userIdentification);
    } catch (e) {
      lastError = e.toString();
      debugPrint('❌ [DailyTaskVM] signIn error=$lastError');
      rethrow;
    }
  }
}
