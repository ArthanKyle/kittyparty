// lib/features/landing/viewmodel/inventory_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/user_provider.dart';
import '../../../core/services/api/item_service.dart';
import '../model/userInventory.dart';

class ItemViewModel extends ChangeNotifier {
  final ItemService _service = ItemService();

  List<UserInventoryItem> inventory = [];
  bool isLoading = false;

  UserProvider? _userProvider;
  bool _isBound = false;

  void _log(String msg) => print("🎒 [ItemVM] $msg");

  // ============================
  // SAFE BIND
  // ============================
  void ensureBound(BuildContext context) {
    if (_isBound) return;

    _userProvider = context.read<UserProvider>();
    _isBound = true;

    _log("User bound: ${_userProvider?.currentUser?.userIdentification}");
    loadInventory();
  }

  // ============================
  // LOAD INVENTORY
  // ============================
  Future<void> loadInventory() async {
    final user = _userProvider?.currentUser;
    if (user == null) return;

    isLoading = true;
    notifyListeners();

    try {
      inventory = await _service.fetchInventory(
        userIdentification: user.userIdentification,
      );
      _log("Loaded ${inventory.length} items");
    } catch (e) {
      _log("❌ loadInventory error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ============================
  // EQUIP (ONE PER SKU)
  // ============================
  Future<void> equip(UserInventoryItem item) async {
    final user = _userProvider?.currentUser;
    if (user == null) return;

    await _service.equipItem(
      inventoryId: item.id,
      userIdentification: user.userIdentification,
    );

    inventory = inventory.map((i) {
      if (i.sku == item.sku) {
        return i.copyWith(equipped: false);
      }
      if (i.id == item.id) {
        return i.copyWith(equipped: true);
      }
      return i;
    }).toList();

    notifyListeners();
  }

  // ============================
  // UNEQUIP
  // ============================
  Future<void> unequip(UserInventoryItem item) async {
    final user = _userProvider?.currentUser;
    if (user == null) return;

    await _service.unequipItem(
      inventoryId: item.id,
      userIdentification: user.userIdentification,
    );

    inventory = inventory
        .map((i) => i.id == item.id ? i.copyWith(equipped: false) : i)
        .toList();

    notifyListeners();
  }
}
