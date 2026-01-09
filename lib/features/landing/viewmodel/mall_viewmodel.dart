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

  late UserProvider _userProvider;

  /// MUST be called once (MallPage init)
  void bindUser(BuildContext context) {
    _userProvider = context.read<UserProvider>();
  }

  /// ============================
  /// LOAD
  /// ============================
  Future<void> loadMall() async {
    isLoading = true;
    notifyListeners();

    items = await _service.fetchMallItems();

    isLoading = false;
    notifyListeners();
  }

  /// ============================
  /// LOOKUPS
  /// ============================
  MallItem? findByAssetKey(String assetKey) {
    try {
      return items.firstWhere((i) => i.assetKey == assetKey);
    } catch (_) {
      return null;
    }
  }

  void select(MallItem item) {
    selectedItem = item;
    notifyListeners();
  }

  /// ============================
  /// VIP / PRICE
  /// ============================
  bool get isVip5 {
    final user = _userProvider.currentUser;
    return user != null && user.vipLevel >= 5;
  }

  int displayPrice(MallItem item) {
    if (isVip5) {
      return (item.priceCoins * 0.05).ceil(); // 95% off
    }
    return item.priceCoins;
  }

  /// ============================
  /// GIFT RULES
  /// ============================
  bool get canGiftSelected {
    if (selectedItem == null) return false;
    if (selectedItem!.giftPriceCoins == null) return false;
    if (isBuying) return false;

    // 🚨 TEMP friend rule hook
    final bool isFriend = true;
    return isFriend;
  }

  /// ============================
  /// BUY
  /// ============================
  Future<void> buySelected(BuildContext context) async {
    if (selectedItem == null || isBuying) return;

    DialogInfo(
      headerText: "Confirm Purchase",
      subText: "Buy ${selectedItem!.name}?",
      confirmText: "Buy",
      onCancel: () => Navigator.of(context, rootNavigator: true).pop(),
      onConfirm: () async {
        Navigator.of(context, rootNavigator: true).pop();

        isBuying = true;
        notifyListeners();

        DialogLoading(subtext: "Processing purchase...")
            .build(context);

        try {
          await _service.buyItem(itemId: selectedItem!.id);

          Navigator.of(context, rootNavigator: true).pop();

          DialogInfo(
            headerText: "Success",
            subText: "Item purchased successfully.",
            confirmText: "OK",
            onConfirm: () =>
                Navigator.of(context, rootNavigator: true).pop(),
            onCancel: () =>
                Navigator.of(context, rootNavigator: true).pop(),
          ).build(context);
        } catch (_) {
          Navigator.of(context, rootNavigator: true).pop();

          DialogInfo(
            headerText: "Failed",
            subText: "Purchase failed.",
            confirmText: "OK",
            onConfirm: () =>
                Navigator.of(context, rootNavigator: true).pop(),
            onCancel: () =>
                Navigator.of(context, rootNavigator: true).pop(),
          ).build(context);
        } finally {
          isBuying = false;
          notifyListeners();
        }
      },
    ).build(context);
  }

  /// ============================
  /// GIFT
  /// ============================
  Future<void> giftSelected(
      BuildContext context, {
        required String targetUserIdentification,
      }) async {
    if (!canGiftSelected || isBuying) return;

    DialogInfo(
      headerText: "Send Gift",
      subText: "Send ${selectedItem!.name} as a gift?",
      confirmText: "Send",
      onCancel: () => Navigator.of(context, rootNavigator: true).pop(),
      onConfirm: () async {
        Navigator.of(context, rootNavigator: true).pop();

        isBuying = true;
        notifyListeners();

        DialogLoading(subtext: "Sending gift...")
            .build(context);

        try {
          await _service.giftItem(
            itemId: selectedItem!.id,
            targetUserIdentification: targetUserIdentification,
          );

          Navigator.of(context, rootNavigator: true).pop();

          DialogInfo(
            headerText: "Gift Sent",
            subText: "Your gift has been delivered.",
            confirmText: "OK",
            onConfirm: () =>
                Navigator.of(context, rootNavigator: true).pop(),
            onCancel: () =>
                Navigator.of(context, rootNavigator: true).pop(),
          ).build(context);
        } catch (_) {
          Navigator.of(context, rootNavigator: true).pop();

          DialogInfo(
            headerText: "Failed",
            subText: "Gift sending failed.",
            confirmText: "OK",
            onConfirm: () =>
                Navigator.of(context, rootNavigator: true).pop(),
            onCancel: () =>
                Navigator.of(context, rootNavigator: true).pop(),
          ).build(context);
        } finally {
          isBuying = false;
          notifyListeners();
        }
      },
    ).build(context);
  }
}
