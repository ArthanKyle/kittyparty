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

    if (userProvider.currentUser != null) {
      wallet.coins = userProvider.currentUser!.coins;
    }


    _userStreamSub = userProvider.userStream.listen((user) {
      if (!hasListeners) return;
      wallet.coins = user.coins;
      notifyListeners();
    });

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
    _userStreamSub?.cancel();
    if (_userListener != null) {
      userProvider.removeListener(_userListener!);
    }
    super.dispose();
  }
}
