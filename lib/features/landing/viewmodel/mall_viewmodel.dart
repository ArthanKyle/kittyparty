// lib/features/landing/viewmodel/mall_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/global_widgets/dialogs/dialog_info.dart';
import '../../../core/global_widgets/dialogs/dialog_loading.dart';
import '../../../core/services/api/mall_service.dart';
import '../../../core/utils/user_provider.dart';
import '../model/mall_item.dart';

class MallViewModel extends ChangeNotifier {
  final MallService _service = MallService();

  List<MallItem> items = [];
  MallItem? selectedItem;

  bool isLoading = false;
  bool isBuying = false;

  UserProvider? _userProvider;

  void _log(String msg) => print("🟣 [MallViewModel] $msg");

  /// MUST be called once (MallPage init)
  void bindUser(BuildContext context) {
    _log("bindUser() called");
    _userProvider = context.read<UserProvider>();
    _log("User bound: ${_userProvider?.currentUser?.userIdentification}");
  }

  // ============================
  // LOAD
  // ============================
  Future<void> loadMall() async {
    _log("loadMall() start");

    isLoading = true;
    notifyListeners();

    try {
      items = await _service.fetchMallItems();
      _log("Fetched ${items.length} mall items");
    } catch (e) {
      _log("❌ loadMall error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
      _log("loadMall() end");
    }
  }

  // ============================
  // LOOKUPS
  // ============================
  String _normalizeKey(String v) =>
      v.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  MallItem? findByAssetKey(String assetKey) {
    _log("findByAssetKey: $assetKey");

    final needle = _normalizeKey(assetKey);

    try {
      final item = items.firstWhere(
            (i) => _normalizeKey(i.assetKey) == needle,
      );
      _log("Item found: ${item.name}");
      return item;
    } catch (_) {
      _log("Item NOT found");
      return null;
    }
  }


  void select(MallItem item) {
    _log("select(): ${item.name}");
    selectedItem = item;
    notifyListeners();
  }

  // ============================
  // VIP / PRICE
  // ============================
  bool get isVip5 {
    final user = _userProvider?.currentUser;
    final result = user != null && user.vipLevel >= 5;
    _log("isVip5 = $result (vipLevel=${user?.vipLevel})");
    return result;
  }

  int displayPrice(MallItem item) {
    final price = isVip5
        ? (item.priceCoins * 0.05).ceil()
        : item.priceCoins;

    _log("displayPrice(${item.name}) = $price");
    return price;
  }

  // ============================
  // GIFT RULES
  // ============================
  bool get canGiftSelected {
    final allowed =
        selectedItem != null &&
            selectedItem!.giftPriceCoins != null &&
            !isBuying;

    _log("canGiftSelected = $allowed");
    return allowed;
  }

  // ============================
  // BUY
  // ============================
  Future<void> buySelected(BuildContext context) async {
    if (selectedItem == null || isBuying) return;

    DialogInfo(
      headerText: "Confirm Purchase",
      subText: "Buy ${selectedItem!.name}?",
      confirmText: "Buy",
      onCancel: () => Navigator.of(context, rootNavigator: true).pop(),
      onConfirm: () async {
        Navigator.of(context, rootNavigator: true).pop(); // close confirm

        isBuying = true;
        notifyListeners();

        DialogLoading(subtext: "Processing purchase...").build(context);

        try {
          await _service.buyItem(
            itemId: selectedItem!.id,
            userIdentification:
            _userProvider!.currentUser!.userIdentification,
          );

          Navigator.of(context, rootNavigator: true).pop(); // close loading

          DialogInfo(
            headerText: "Purchase Successful",
            subText:
            "${selectedItem!.name} has been added to your inventory.",
            confirmText: "OK",
            onConfirm: () =>
                Navigator.of(context, rootNavigator: true).pop(),
            onCancel: () =>
                Navigator.of(context, rootNavigator: true).pop(),
          ).build(context);

        } catch (e) {
          Navigator.of(context, rootNavigator: true).pop(); // close loading
          _log("❌ Purchase failed: $e");
        } finally {
          isBuying = false;
          notifyListeners();
        }
      },
    ).build(context);
  }


  // ============================
  // GIFT
  // ============================
  Future<void> giftSelected(
      BuildContext context, {
        required String targetUserIdentification,
      }) async {
    _log("giftSelected() called → target=$targetUserIdentification");

    if (!canGiftSelected || isBuying) {
      _log("❌ giftSelected blocked");
      return;
    }

    DialogInfo(
      headerText: "Send Gift",
      subText: "Send ${selectedItem!.name} as a gift?",
      confirmText: "Send",
      onCancel: () => Navigator.of(context, rootNavigator: true).pop(),
      onConfirm: () async {
        Navigator.of(context, rootNavigator: true).pop();

        isBuying = true;
        notifyListeners();

        DialogLoading(subtext: "Sending gift...").build(context);

        try {
          await _service.giftItem(
            itemId: selectedItem!.id,
            targetUserIdentification: targetUserIdentification,
            userIdentification: _userProvider!.currentUser!.userIdentification,
          );
          _log("✅ Gift sent");
          Navigator.of(context, rootNavigator: true).pop();
        } catch (e) {
          _log("❌ Gift failed: $e");
          Navigator.of(context, rootNavigator: true).pop();
        } finally {
          isBuying = false;
          notifyListeners();
          _log("giftSelected() end");
        }
      },
    ).build(context);
  }
}
