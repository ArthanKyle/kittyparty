// inventory_viewmodel.dart  (ItemViewModel)
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
  BuildContext? _context;
  bool _isBound = false;

  // ✅ track which user this VM is currently bound to
  String? _boundUserIdentification;

  void _log(String msg) => debugPrint("🎒 [ItemVM] $msg");

  // ===============================
  // RESET (call on logout OR user switch)
  // ===============================
  void reset() {
    _log("🧽 reset()");
    isEquipping = false;
    isLoading = false;
    inventory = [];

    _context = null;
    _userProvider = null;
    _isBound = false;
    _boundUserIdentification = null;

    notifyListeners();
  }

  // ===============================
  // SAFE BIND + USER SWITCH DETECT
  // ===============================
  void ensureBound(BuildContext context) {
    final up = context.read<UserProvider>();
    final newUserId = up.currentUser?.userIdentification;

    // ✅ If already bound to a different user, reset and rebind
    if (_isBound &&
        _boundUserIdentification != null &&
        _boundUserIdentification != newUserId) {
      _log("🔁 user changed: $_boundUserIdentification -> $newUserId");
      reset();
    }

    if (_isBound) return;

    _context = context;
    _userProvider = up;
    _boundUserIdentification = newUserId;
    _isBound = true;

    Future.microtask(loadInventory);
  }

  // ===============================
  // LOAD INVENTORY
  // ===============================
  Future<void> loadInventory() async {
    final user = _userProvider?.currentUser;

    // ✅ if logged out, wipe inventory so UI won't reuse old user's items
    if (user == null) {
      inventory = [];
      notifyListeners();
      return;
    }

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
      _context?.read<ProfileViewModel>().syncFromInventory(inventory);
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
    notifyListeners();

    _log("▶ EQUIP ${item.sku} (${item.id})");

    final user = _userProvider?.currentUser;
    if (user == null) {
      isEquipping = false;
      notifyListeners();
      return;
    }

    try {
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
      _context?.read<ProfileViewModel>().syncFromInventory(inventory);

      _log("✔ EQUIP DONE");
    } catch (e) {
      _log("❌ equip error: $e");
    } finally {
      isEquipping = false;
      notifyListeners();
    }
  }

  // ===============================
  // UNEQUIP
  // ===============================
  Future<void> unequip(UserInventoryItem item) async {
    final user = _userProvider?.currentUser;
    if (user == null) return;

    try {
      await _service.unequipItem(
        inventoryId: item.id,
        userIdentification: user.userIdentification,
      );

      inventory = inventory
          .map((i) => i.id == item.id ? i.copyWith(equipped: false) : i)
          .toList();

      _context?.read<ProfileViewModel>().syncFromInventory(inventory);

      notifyListeners();
    } catch (e) {
      _log("❌ unequip error: $e");
    }
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
