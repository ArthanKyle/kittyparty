import 'package:flutter/material.dart';
import '../../../core/utils/user_provider.dart';
import '../model/wallet.dart';

class WalletViewModel extends ChangeNotifier {
  final UserProvider userProvider;
  Wallet wallet;

  WalletViewModel({required this.userProvider})
      : wallet = Wallet(coins: 0) {
    // Set initial coins if user is already loaded
    if (userProvider.currentUser != null) {
      wallet.coins = userProvider.currentUser!.coins;
    }

    // Listen to user stream for real-time updates
    userProvider.userStream.listen((user) {
      wallet.coins = user.coins;
      notifyListeners();
    });

    // If currentUser is loaded later, listen once
    if (userProvider.currentUser == null) {
      userProvider.addListener(() {
        if (userProvider.currentUser != null) {
          wallet.coins = userProvider.currentUser!.coins;
          notifyListeners();
        }
      });
    }
  }

  void updateCoins(int newCoins) {
    userProvider.updateCoins(newCoins);
  }
}
