import 'package:flutter/foundation.dart';
import '../../../core/services/api/wealth_service.dart';
import '../model/wealth.dart';

class WealthViewModel extends ChangeNotifier {
  final WealthService service;

  WealthViewModel({required this.service});

  bool isLoading = false;
  String? error;
  WealthStatus? status;

  Future<void> load({required String userIdentification}) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      status = await service.fetchMe(userIdentification: userIdentification);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh({required String userIdentification}) =>
      load(userIdentification: userIdentification);
}
