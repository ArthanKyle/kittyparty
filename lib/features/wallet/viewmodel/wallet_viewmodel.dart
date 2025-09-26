import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/utils/user_provider.dart';
import '../model/wallet.dart';

class WalletViewModel extends ChangeNotifier {
  final UserProvider userProvider;
  Wallet wallet;
  StreamSubscription? _userStreamSub;
  VoidCallback? _userListener;

  WalletViewModel({required this.userProvider})
      : wallet = Wallet(coins: 0) {
    // Set initial coins if user is already loaded
    if (userProvider.currentUser != null) {
      wallet.coins = userProvider.currentUser!.coins;
    }

    // Listen to user stream for real-time updates
    _userStreamSub = userProvider.userStream.listen((user) {
      if (!hasListeners) return; // prevent notify after dispose
      wallet.coins = user.coins;
      notifyListeners();
    });

    // If currentUser is loaded later, listen once
    if (userProvider.currentUser == null) {
      _userListener = () {
        if (userProvider.currentUser != null) {
          wallet.coins = userProvider.currentUser!.coins;
          notifyListeners();
        }
      };
      userProvider.addListener(_userListener!);
    }
  }

  void updateCoins(int newCoins) {
    userProvider.updateCoins(newCoins);
  }

  @override
  void dispose() {
    // Cancel subscriptions/listeners to avoid notify after dispose
    _userStreamSub?.cancel();
    if (_userListener != null) {
      userProvider.removeListener(_userListener!);
    }
    super.dispose();
  }
}
