import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../core/utils/user_provider.dart';
import '../../../core/services/api/socket_service.dart';
import '../../../core/services/api/conversion_recharge.dart';
import '../model/diamond.dart';

class DiamondViewModel extends ChangeNotifier {
  final UserProvider userProvider;
  final SocketService socketService;
  final ConversionService conversionService;

  VoidCallback? _userListener;
  StreamSubscription? _diamondSocketSub;
  StreamSubscription? _coinSocketSub;

  bool _disposed = false;
  bool isConverting = false;

  Diamond diamond;

  DiamondViewModel({
    required this.userProvider,
    required this.socketService,
  })  : conversionService =
  ConversionService(baseUrl: dotenv.env['BASE_URL']!),
        diamond = Diamond(diamonds: 0) {
    // Initial sync (safe even if user is null)
    _syncFromUser();

    // Listen to UserProvider safely
    _userListener = () {
      _syncFromUser();
    };
    userProvider.addListener(_userListener!);

    // Socket listeners
    _listenToSocket();
  }

  void _syncFromUser() {
    if (_disposed) return;

    final user = userProvider.currentUser;
    if (user == null) return;

    if (diamond.diamonds != user.diamonds) {
      diamond.diamonds = user.diamonds;
      notifyListeners();
    }
  }

  void _listenToSocket() {
    _diamondSocketSub =
        socketService.diamondsStream.listen((newDiamonds) {
          if (_disposed) return;

          diamond.diamonds = newDiamonds;
          userProvider.updateDiamonds(newDiamonds);
          notifyListeners();
        });

    _coinSocketSub = socketService.coinsStream.listen((newCoins) {
      if (_disposed) return;
      userProvider.updateCoins(newCoins);
    });
  }

  Future<void> convertCoinsToDiamonds(int coinsToConvert) async {
    final user = userProvider.currentUser;
    if (user == null) return;

    isConverting = true;
    notifyListeners();

    try {
      await conversionService.convertCoinsToDiamonds(
        userId: user.id,
        coins: coinsToConvert,
      );
    } finally {
      isConverting = false;
      if (!_disposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;

    if (_userListener != null) {
      userProvider.removeListener(_userListener!);
    }

    _diamondSocketSub?.cancel();
    _coinSocketSub?.cancel();

    super.dispose();
  }
}
