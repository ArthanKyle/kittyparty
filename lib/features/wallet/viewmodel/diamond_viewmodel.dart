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

  bool _disposed = false;
  bool isConverting = false;

  Diamond diamond;

  DiamondViewModel({
    required this.userProvider,
    required this.socketService,
  })  : conversionService = ConversionService(baseUrl: dotenv.env['BASE_URL']!),
        diamond = Diamond(
          diamonds: userProvider.currentUser?.diamonds ?? 0,
        ) {
    _loadInitialDiamonds();
    _listenToSocket();
  }

  void _loadInitialDiamonds() {
    final diamonds = userProvider.currentUser?.diamonds ?? 0;
    diamond.diamonds = diamonds;
    if (!_disposed) notifyListeners();
  }

  void _listenToSocket() {
    socketService.diamondsStream.listen((newDiamonds) {
      if (_disposed) return;
      print("💎 Socket update received: $newDiamonds");
      diamond.diamonds = newDiamonds;

      userProvider.updateDiamonds(newDiamonds);

      notifyListeners();
    });

    socketService.coinsStream.listen((newCoins) {
      if (_disposed) return;
      userProvider.updateCoins(newCoins);
    });
  }

  Future<void> convertCoinsToDiamonds(int coinsToConvert) async {
    final user = userProvider.currentUser;
    if (user == null) return;

    isConverting = true;
    if (!_disposed) notifyListeners();

    try {
      print("🔹 Converting coins for user: ${user.id}");
      print("🔹 Coins to convert: $coinsToConvert");

      await conversionService.convertCoinsToDiamonds(
        userId: user.id,
        coins: coinsToConvert,
      );

      print("✅ Conversion API call successful. Waiting for socket update.");

    } catch (e) {
      print("❌ convertCoinsToDiamonds failed: $e");
      rethrow;
    } finally {
      isConverting = false;
      if (!_disposed) notifyListeners();
    }
  }

  void refreshDiamondsFromUser() {
    final diamonds = userProvider.currentUser?.diamonds ?? 0;
    diamond.diamonds = diamonds;
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}