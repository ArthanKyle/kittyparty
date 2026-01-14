import 'package:flutter/material.dart';

import '../../../core/services/api/charm_service.dart';
import '../model/wealth.dart';

class CharmViewModel extends ChangeNotifier {
  final CharmService service;

  CharmViewModel({required this.service});

  WealthStatus? status;
  bool isLoading = false;
  String? error;

  /* =========================
   * LOAD
   * ========================= */
  Future<void> load({
    required String userIdentification,
  }) async {
    if (isLoading) return;

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      status = await service.fetchCharmStatus(
        userIdentification: userIdentification,
      );
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /* =========================
   * REFRESH
   * ========================= */
  Future<void> refresh({
    required String userIdentification,
  }) async {
    status = null;
    await load(userIdentification: userIdentification);
  }
}
