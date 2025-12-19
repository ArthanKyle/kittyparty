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

  Future<void> signIn(String userIdentification) async {
    try {
      await _service.signIn(userIdentification);
      await fetchDailyTasks(userIdentification);
    } catch (e) {
      throw e.toString();
    }
  }
}
