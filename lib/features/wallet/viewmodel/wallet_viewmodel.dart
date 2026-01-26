import 'dart:async';
import 'package:flutter/foundation.dart';

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

    _coinsSub = socketService.coinsStream.listen((coins) {
      // Ignore invalid zero overwrites
      if (coins == 0 && _wallet.coins > 0) {
        debugPrint('⚠️ Ignoring socket coins=0 overwrite');
        return;
      }

      _wallet = _wallet.copyWith(coins: coins);
      notifyListeners();

      debugPrint("🪙 Wallet socket → coins=$coins");
    });

    _diamondsSub = socketService.diamondsStream.listen((diamonds) {
      if (diamonds == 0 && _wallet.diamonds > 0) {
        debugPrint('⚠️ Ignoring socket diamonds=0 overwrite');
        return;
      }

      _wallet = _wallet.copyWith(diamonds: diamonds);
      notifyListeners();

      debugPrint("💎 Wallet socket → diamonds=$diamonds");
    });
  }

  /// REST snapshot (used only on page load / fallback)
  Future<void> refresh() async {
    final user = userProvider.currentUser;
    if (user == null) return;

    final fetched =
    await walletService.fetchWallet(user.userIdentification);

    _wallet = fetched;
    notifyListeners();

    debugPrint(
      "📦 Wallet REST snapshot → coins=${fetched.coins} diamonds=${fetched.diamonds}",
    );
  }

  Future<void> convertCoinsToDiamonds(int coins) async {
    final user = userProvider.currentUser;
    if (user == null) return;

    final result = await conversionService.convertCoinsToDiamonds(
      userIdentification: user.userIdentification,
      coins: coins,
    );

    _wallet = _wallet.copyWith(
      coins: result.coins,
      diamonds: result.diamonds,
    );

    notifyListeners();

    debugPrint(
      '[WalletVM] Conversion success → coins=${result.coins} diamonds=${result.diamonds}',
    );
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
