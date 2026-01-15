import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/user_provider.dart';
import '../../../core/services/api/item_service.dart';
import '../model/userInventory.dart';
import 'profile_viewmodel.dart';

class ItemViewModel extends ChangeNotifier {
  final ItemService _service = ItemService();

  bool isEquipping = false;
  bool isLoading = false;
  List<UserInventoryItem> inventory = [];

  UserProvider? _userProvider;
  BuildContext? _context; // ✅ REQUIRED
  bool _isBound = false;

  void _log(String msg) => debugPrint("🎒 [ItemVM] $msg");

  // ===============================
  // SAFE BIND
  // ===============================
  void ensureBound(BuildContext context) {
    if (_isBound) return;

    _context = context;
    _userProvider = context.read<UserProvider>();
    _isBound = true;

    Future.microtask(loadInventory);
  }

  // ===============================
  // LOAD INVENTORY
  // ===============================
  Future<void> loadInventory() async {
    final user = _userProvider?.currentUser;
    if (user == null) return;

    isLoading = true;
    notifyListeners();

    try {
      inventory = await _service.fetchInventory(
        userIdentification: user.userIdentification,
      );

      for (final i in inventory) {
        _log("• ${i.sku} equipped=${i.equipped}");
      }

      // 🔥 sync profile after load
      _context
          ?.read<ProfileViewModel>()
          .syncFromInventory(inventory);
    } catch (e) {
      _log("❌ loadInventory error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ===============================
  // EQUIP (ONE PER CATEGORY)
  // ===============================
  Future<void> equip(UserInventoryItem item) async {
    if (isEquipping) return;
    isEquipping = true;

    _log("▶ EQUIP ${item.sku} (${item.id})");

    final user = _userProvider?.currentUser;
    if (user == null) return;

    await _service.equipItem(
      inventoryId: item.id,
      userIdentification: user.userIdentification,
    );

    final category = _deriveCategory(item.sku);
    _log("Category resolved: $category");

    inventory = inventory.map((i) {
      // ✅ EQUIPPED ITEM FIRST
      if (i.id == item.id) {
        return i.copyWith(equipped: true);
      }

      // ✅ UNEQUIP OTHERS IN SAME CATEGORY
      if (_deriveCategory(i.sku) == category) {
        return i.copyWith(equipped: false);
      }

      return i;
    }).toList();

    // 🔥 SYNC TO PROFILE
    _context
        ?.read<ProfileViewModel>()
        .syncFromInventory(inventory);

    isEquipping = false;
    notifyListeners();

    _log("✔ EQUIP DONE");
  }

  // ===============================
  // UNEQUIP
  // ===============================
  Future<void> unequip(UserInventoryItem item) async {
    final user = _userProvider?.currentUser;
    if (user == null) return;

    await _service.unequipItem(
      inventoryId: item.id,
      userIdentification: user.userIdentification,
    );

    inventory = inventory
        .map((i) =>
    i.id == item.id ? i.copyWith(equipped: false) : i)
        .toList();

    _context
        ?.read<ProfileViewModel>()
        .syncFromInventory(inventory);

    notifyListeners();
  }

  // ===============================
  // CATEGORY DERIVATION
  // ===============================
  String _deriveCategory(String sku) {
    final s = sku.toUpperCase();
    if (s.contains('FRAME') || s.contains('AVATAR')) return 'AVATAR';
    if (s.startsWith('MOUNT')) return 'MOUNT';
    if (s.contains('NAMEPLATE')) return 'NAMEPLATE';
    if (s.contains('PROFILE')) return 'PROFILECARD';
    if (s.contains('CHAT')) return 'CHATBUBBLE';
    return 'UNKNOWN';
  }
}
