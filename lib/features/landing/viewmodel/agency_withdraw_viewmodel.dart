import 'package:flutter/material.dart';
import '../../../core/services/api/agency_withdraw_service.dart';
import '../../../core/utils/user_provider.dart';
import '../model/agency_withdraw.dart';

class AgencyWithdrawViewModel extends ChangeNotifier {
  final UserProvider userProvider;
  final String agencyCode;

  AgencyWithdrawViewModel({
    required this.userProvider,
    required this.agencyCode,
  });

  bool isLoading = false;
  String? error;

  List<AgencyWithdrawDto> withdrawals = [];

  Future<void> load() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      withdrawals = await AgencyWithdrawService.fetchMyWithdrawals(
        userProvider: userProvider,
      );
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> requestWithdraw(int diamonds) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      await AgencyWithdrawService.requestWithdraw(
        userProvider: userProvider,
        agencyCode: agencyCode,
        diamonds: diamonds,
      );

      await load(); // refresh history
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
