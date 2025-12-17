import 'dart:async';
import 'package:flutter/material.dart';

import '../../../core/services/api/conversion_recharge.dart';
import '../../../core/services/api/socket_service.dart';
import '../../../core/services/api/wallet_service.dart';
import '../../../core/utils/user_provider.dart';
import '../model/wallet.dart';

class WalletViewModel extends ChangeNotifier {
  final WalletService walletService;
  final ConversionService conversionService;
  final SocketService socketService;
  final UserProvider userProvider;

  Wallet _wallet = const Wallet(coins: 0, diamonds: 0);
  Wallet get wallet => _wallet;

  StreamSubscription? _coinsSub;
  StreamSubscription? _diamondsSub;

  WalletViewModel({
    required this.userProvider,
    required this.walletService,
    required this.conversionService,
    required this.socketService,
  }) {
    _init();
  }

  void _init() {
    refresh();

    // 🔥 SOCKET IS SOURCE OF TRUTH
    _coinsSub = socketService.coinsStream.listen((coins) {
      _wallet = _wallet.copyWith(coins: coins);
      notifyListeners();
      print("🪙 WalletVM socket → coins=$coins");
    });

    _diamondsSub = socketService.diamondsStream.listen((diamonds) {
      _wallet = _wallet.copyWith(diamonds: diamonds);
      notifyListeners();
      print("💎 WalletVM socket → diamonds=$diamonds");
    });
  }

  /// REST snapshot (ONLY when page opens)
  Future<void> refresh() async {
    final user = userProvider.currentUser;
    if (user == null) return;

    final fetched = await walletService.fetchWallet(
      user.userIdentification,
    );

    _wallet = fetched;
    notifyListeners();

    print("📦 WalletVM REST snapshot → coins=${fetched.coins} diamonds=${fetched.diamonds}");
  }

  Future<void> convertCoinsToDiamonds(int coins) async {
    final user = userProvider.currentUser;
    if (user == null) return;

    await conversionService.convertCoinsToDiamonds(
      userId: user.id,
      coins: coins,
    );
    // socket will update wallet
  }

  int get coins => _wallet.coins;
  int get diamonds => _wallet.diamonds;

  @override
  void dispose() {
    _coinsSub?.cancel();
    _diamondsSub?.cancel();
    super.dispose();
  }
}
