import 'dart:async';
import 'package:flutter/material.dart';

import '../../../core/services/api/conversion_recharge.dart';
import '../../../core/services/api/wallet_service.dart';
import '../../../core/utils/user_provider.dart';
import '../model/wallet.dart';

class WalletViewModel extends ChangeNotifier {
  final UserProvider userProvider;
  final WalletService walletService;
  final ConversionService conversionService;

  Wallet _wallet = const Wallet(coins: 0, diamonds: 0);
  Wallet get wallet => _wallet;

  StreamSubscription? _userStreamSub;
  bool _disposed = false;
  bool _isFetching = false;

  WalletViewModel({
    required this.userProvider,
    required this.walletService,
    required this.conversionService,
  }) {
    _listenToUser();
  }

  void _listenToUser() {
    _userStreamSub = userProvider.userStream.listen((user) {
      if (_disposed) return;

      _wallet = _wallet.copyWith(
        coins: user.coins,
        diamonds: user.diamonds,
      );
      notifyListeners();
    });
  }

  /// 🔄 Call this every time WalletPage is opened
  Future<void> refresh() async {
    if (_isFetching) return;

    final user = userProvider.currentUser;
    if (user == null) return;

    try {
      _isFetching = true;
      debugPrint("🟡 [WalletVM] Fetching wallet...");

      final fetched =
      await walletService.fetchWallet(user.userIdentification);

      _wallet = fetched;
      debugPrint("🟢 [WalletVM] Wallet updated: $fetched");
      notifyListeners();
    } finally {
      _isFetching = false;
    }
  }

  Future<void> convertCoinsToDiamonds(int coins) async {
    final user = userProvider.currentUser;
    if (user == null) return;

    await conversionService.convertCoinsToDiamonds(
      userId: user.id,
      coins: coins,
    );
    // socket / user stream will update wallet
  }

  int get coins => _wallet.coins;
  int get diamonds => _wallet.diamonds;

  @override
  void dispose() {
    _disposed = true;
    _userStreamSub?.cancel();
    super.dispose();
  }
}
