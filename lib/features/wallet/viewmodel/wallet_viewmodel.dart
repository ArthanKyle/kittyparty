import 'package:flutter/material.dart';
import '../../../core/utils/user_provider.dart';
import '../model/wallet.dart';

class WalletViewModel extends ChangeNotifier {
  final UserProvider userProvider;
  Wallet wallet;

  WalletViewModel({required this.userProvider})
      : wallet = Wallet(coins: userProvider.currentUser?.coins ?? 0) {
    // Listen to UserProvider for real-time coin updates
    userProvider.userStream.listen((user) {
      wallet.coins = user.coins;
      notifyListeners();
    });
  }

  void updateCoins(int newCoins) {
    userProvider.updateCoins(newCoins);
  }
}
