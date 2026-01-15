import 'package:flutter/material.dart';

import '../../../core/services/api/gift_transaction_service.dart';
import '../../../core/services/api/recharge_service.dart';
import '../../../core/services/api/room_income_service.dart';

import '../model/gift_transaction.dart';
import '../../wallet/model/transaction.dart';

enum TransactionTab {
  gifts,
  recharges,
  roomIncome,
}

class TransactionViewModel extends ChangeNotifier {
  final GiftTransactionService giftService;
  final RechargeService rechargeService;
  final RoomIncomeService roomIncomeService;

  TransactionViewModel({
    required this.giftService,
    required this.rechargeService,
    required this.roomIncomeService,
  });

  /* =============================
     STATE
  ============================== */

  bool loading = false;
  String? error;

  TransactionTab activeTab = TransactionTab.gifts;

  List<GiftTransaction> _gifts = [];
  List<TransactionModel> _recharges = [];
  RoomIncomeSummary? _roomIncomeSummary;

  /* =============================
     GETTERS
  ============================== */

  List<GiftTransaction> get gifts => _gifts;
  List<TransactionModel> get recharges => _recharges;
  RoomIncomeSummary? get roomIncomeSummary => _roomIncomeSummary;

  dynamic get currentData {
    switch (activeTab) {
      case TransactionTab.recharges:
        return _recharges;
      case TransactionTab.roomIncome:
        return _roomIncomeSummary;
      case TransactionTab.gifts:
      default:
        return _gifts;
    }
  }

  /* =============================
     LOADERS
  ============================== */

  Future<void> loadGifts(String userIdentification) async {
    print("🟣 [TransactionVM] loadGifts START user=$userIdentification");

    loading = true;
    error = null;
    notifyListeners();

    try {
      _gifts =
      await giftService.getUserGiftTransactions(userIdentification);

      print(
        "🟢 [TransactionVM] loadGifts SUCCESS count=${_gifts.length}",
      );
    } catch (e, st) {
      error = e.toString();
      print("🔴 [TransactionVM] loadGifts ERROR $e");
      print(st);
    } finally {
      loading = false;
      notifyListeners();
      print("🟣 [TransactionVM] loadGifts END");
    }
  }

  Future<void> loadRecharges(String userIdentification) async {
    print("🟣 [TransactionVM] loadRecharges START user=$userIdentification");

    loading = true;
    error = null;
    notifyListeners();

    try {
      _recharges =
      await rechargeService.getUserHistory(userIdentification);

      print(
        "🟢 [TransactionVM] loadRecharges SUCCESS count=${_recharges.length}",
      );
    } catch (e, st) {
      error = e.toString();
      print("🔴 [TransactionVM] loadRecharges ERROR $e");
      print(st);
    } finally {
      loading = false;
      notifyListeners();
      print("🟣 [TransactionVM] loadRecharges END");
    }
  }

  Future<void> loadRoomIncome(String roomId) async {
    print("🟣 [TransactionVM] loadRoomIncome START roomId=$roomId");

    loading = true;
    error = null;
    notifyListeners();

    try {
      _roomIncomeSummary =
      await roomIncomeService.getSummary(roomId);

      if (_roomIncomeSummary == null) {
        print(
          "🟡 [TransactionVM] loadRoomIncome EMPTY (no summary)",
        );
      } else {
        print(
          "🟢 [TransactionVM] loadRoomIncome SUCCESS "
              "today=${_roomIncomeSummary!.contributionTodayCoins} "
              "total=${_roomIncomeSummary!.contributionTotalCoins}",
        );
      }
    } catch (e, st) {
      error = e.toString();
      print("🔴 [TransactionVM] loadRoomIncome ERROR $e");
      print(st);
    } finally {
      loading = false;
      notifyListeners();
      print("🟣 [TransactionVM] loadRoomIncome END");
    }
  }

  /* =============================
     TAB CONTROL
  ============================== */

  void setTab({
    required TransactionTab tab,
    required String userIdentification,
    String? roomId,
  }) {
    print(
      "🔵 [TransactionVM] setTab from=$activeTab to=$tab "
          "user=$userIdentification roomId=$roomId",
    );

    if (activeTab == tab) {
      print("⚪ [TransactionVM] setTab SKIPPED (same tab)");
      return;
    }

    activeTab = tab;
    notifyListeners();

    if (tab == TransactionTab.gifts && _gifts.isEmpty) {
      print("➡️ [TransactionVM] trigger loadGifts");
      loadGifts(userIdentification);
    }

    if (tab == TransactionTab.recharges && _recharges.isEmpty) {
      print("➡️ [TransactionVM] trigger loadRecharges");
      loadRecharges(userIdentification);
    }

    if (tab == TransactionTab.roomIncome) {
      if (roomId == null) {
        print(
          "🟡 [TransactionVM] roomIncome tab selected but roomId is null",
        );
      } else if (_roomIncomeSummary == null) {
        print("➡️ [TransactionVM] trigger loadRoomIncome");
        loadRoomIncome(roomId);
      }
    }
  }

  /* =============================
     HELPERS (UI)
  ============================== */

  bool isGift(dynamic tx) => tx is GiftTransaction;
  bool isRecharge(dynamic tx) => tx is TransactionModel;
  bool isRoomIncome() => activeTab == TransactionTab.roomIncome;
}
