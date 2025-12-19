import 'package:flutter/material.dart';
import '../../../core/services/api/dailyTask_service.dart';
import '../model/dailyTask.dart';

class DailyTaskViewModel extends ChangeNotifier {
  final DailyTaskService _service;

  DailyTaskViewModel(this._service);

  List<DailyTask> dailyTasks = [];
  bool isLoading = false;

  Future<void> fetchDailyTasks(String token) async {
    isLoading = true;
    notifyListeners();

    try {
      dailyTasks = await _service.fetchDailyTasks(token);
    } catch (e) {
      dailyTasks = [];
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> signIn(String token) async {
    await _service.signIn(token);
    await fetchDailyTasks(token);
  }
}
