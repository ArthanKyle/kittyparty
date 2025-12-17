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

  WalletViewModel({
    required this.userProvider,
    required this.walletService,
    required this.conversionService,
  }) {
    _init();
  }

  void _init() {
    _fetchWallet();

    _userStreamSub = userProvider.userStream.listen((user) {
      if (_disposed) return;

      _wallet = _wallet.copyWith(
        coins: user.coins,
        diamonds: user.diamonds,
      );

      notifyListeners();
    });
  }

  Future<void> _fetchWallet() async {
    final user = userProvider.currentUser;
    if (user == null) return;

    final fetched = await walletService.fetchWallet(
      user.userIdentification,
    );

    _wallet = fetched;
    notifyListeners();
  }

  Future<void> convertCoinsToDiamonds(int coins) async {
    final user = userProvider.currentUser;
    if (user == null) return;

    await conversionService.convertCoinsToDiamonds(
      userId: user.id,
      coins: coins,
    );

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
