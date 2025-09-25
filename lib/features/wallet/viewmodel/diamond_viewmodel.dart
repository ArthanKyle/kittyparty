import 'package:flutter/material.dart';
import '../../../core/utils/user_provider.dart';
import '../model/diamond.dart';

class DiamondViewModel extends ChangeNotifier {
  final UserProvider userProvider;
  Diamond diamond;

  DiamondViewModel({required this.userProvider})
      : diamond = Diamond(diamonds: userProvider.currentUser?.diamonds ?? 0) {
    userProvider.userStream.listen((user) {
      diamond.diamonds = user.diamonds;
      notifyListeners();
    });
  }

  void updateDiamonds(int newDiamonds) {
    diamond.diamonds = newDiamonds;
    notifyListeners();
  }
}
