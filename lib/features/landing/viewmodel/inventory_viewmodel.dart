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
  String? _boundUserIdentification;

  void _log(String msg) => debugPrint("🎒 [ItemVM] $msg");

  // ===============================
  // RESET
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
  // SAFE BIND
  // ===============================
  void ensureBound(BuildContext context) {
    final up = context.read<UserProvider>();
    final newUserId = up.currentUser?.userIdentification;

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
        _log("• ${i.assetKey} equipped=${i.equipped}");
      }

      _context?.read<ProfileViewModel>().syncFromInventory(inventory);
    } catch (e) {
      _log("❌ loadInventory error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ===============================
  // EQUIP
  // ===============================
  Future<void> equip(UserInventoryItem item) async {
    if (isEquipping) return;
    isEquipping = true;
    notifyListeners();

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

      inventory = inventory.map((i) {
        if (i.id == item.id) {
          return i.copyWith(equipped: true);
        }
        if (i.assetType == item.assetType) {
          return i.copyWith(equipped: false);
        }
        return i;
      }).toList();

      _context?.read<ProfileViewModel>().syncFromInventory(inventory);
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
}
