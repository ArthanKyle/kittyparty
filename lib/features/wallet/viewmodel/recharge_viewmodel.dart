import 'package:flutter/material.dart';
import '../../../core/services/api/recharge_service.dart';
import '../../../core/services/api/socket_service.dart';
import '../../../core/utils/user_provider.dart';
import '../model/recharge.dart';
import '../model/transaction.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class RechargeViewModel extends ChangeNotifier {
  final UserProvider userProvider;
  final RechargeService rechargeService;
  final SocketService socketService;
  bool _disposed = false;

  RechargeViewModel({
    required this.rechargeService,
    required this.userProvider,
    required this.socketService,
  }) {
    _initSocket();
  }

  @override
  void dispose() {
    _disposed = true;
    socketService.dispose();
    super.dispose();
  }

  List<RechargePackage> packages = [];
  RechargePackage? selectedPackage;
  bool isLoading = false;
  bool isPaymentProcessing = false;


  double displayAmount = 0.0;
  String displayCurrency = "USD";
  String displaySymbol = "\$";

  void _initSocket() {
    final userId = userProvider.currentUser?.id;
    if (userId == null) return;

    socketService.initSocket(
      userId,
          (coins) {
        if (!_disposed) {
          userProvider.currentUser?.coins = coins;
          notifyListeners();
        }
      },
      onBonusHidden: () {
        if (!_disposed) _hideBonusesIfNotFirstRecharge();
      },
    );
  }

  void _hideBonusesIfNotFirstRecharge() {
    final user = userProvider.currentUser;
    if (user == null || user.isFirstTimeRecharge) return; // Only hide if it's NOT first recharge
    if (packages.isEmpty) return;

    // Map all packages to remove bonus
    packages = packages.map((pkg) {
      return RechargePackage(
        coins: pkg.coins,
        bonus: 0, // remove bonus
        price: pkg.price,
        symbol: pkg.symbol,
        currency: pkg.currency,
      );
    }).toList();

    if (!_disposed) notifyListeners();
    print("📦 Bonuses hidden for user ${user.id}");
  }


  Future<void> fetchPackages() async {
    final user = userProvider.currentUser;
    if (user == null) return;

    isLoading = true;
    if (!_disposed) notifyListeners();

    try {
      packages = await rechargeService.fetchPackages(user.id);
      if (!user.isFirstTimeRecharge) _hideBonusesIfNotFirstRecharge();
      if (packages.isNotEmpty) selectedPackage ??= packages.first;

      displayAmount = selectedPackage!.price;
      displayCurrency = user.countryCode.toUpperCase();
      displaySymbol = _getCurrencySymbol(displayCurrency);
    } catch (e) {
      print("fetchPackages failed: $e");
    } finally {
      isLoading = false;
      if (!_disposed) notifyListeners();
    }
  }

  void selectPackage(RechargePackage pkg) {
    selectedPackage = pkg;
    displayAmount = pkg.price;
    displayCurrency = userProvider.currentUser?.countryCode.toUpperCase() ?? "USD";
    displaySymbol = _getCurrencySymbol(displayCurrency);
    if (!_disposed) notifyListeners();
  }

  Future<TransactionModel?> createPaymentIntent({String? method}) async {
    final user = userProvider.currentUser;
    if (user == null || selectedPackage == null) throw Exception("No package or user");

    isPaymentProcessing = true;
    if (!_disposed) notifyListeners();

    try {
      final json = await rechargeService.createPaymentIntent(
        userId: user.id,
        amount: selectedPackage!.price,
        countryCode: user.countryCode.isNotEmpty ? user.countryCode : 'PH',
        method: method,
        coins: selectedPackage!.coins,
      );

      final clientSecret = json['clientSecret'] as String?;
      final transactionId = json['transactionId'] as String?;
      final display = json['display'] as Map<String, dynamic>?;

      if (clientSecret == null || transactionId == null) return null;

      displayAmount = display?['amount']?.toDouble() ?? selectedPackage!.price;
      displayCurrency = (display?['currency'] ?? 'USD').toString().toUpperCase();
      displaySymbol = display?['symbol'] ?? _getCurrencySymbol(displayCurrency);

      return TransactionModel(
        id: transactionId,
        userId: user.id,
        paymentIntentId: null,
        clientSecret: clientSecret,
        paymentMethod: method ?? 'card',
        status: 'pending',
        amount: displayAmount,
        currency: displayCurrency,
        coinsBase: selectedPackage!.coins,
        coinsBonus: 0,
        coinsFinal: selectedPackage!.coins,
        transactionRef: '',
        providerId: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      print("createPaymentIntent error: $e");
      rethrow;
    } finally {
      isPaymentProcessing = false;
      if (!_disposed) notifyListeners();
    }
  }

  Future<void> presentPaymentSheet({required String clientSecret}) async {
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: 'Kittyparty',
        style: ThemeMode.light,
      ),
    );
    await Stripe.instance.presentPaymentSheet();
  }

  Future<void> confirmPayment(String transactionId) async {
    final user = userProvider.currentUser;
    if (user == null) return;

    isPaymentProcessing = true;
    if (!_disposed) notifyListeners();

    try {
      final topUp = await rechargeService.confirmPayment(transactionId: transactionId);
      final coinsFinal = topUp.coinsFinal;

      userProvider.updateCoins(coinsFinal);

      if (user.isFirstTimeRecharge) {
        user.isFirstTimeRecharge = false;
        print("💡 First-time recharge completed for user ${user.id}");
      }

      // 🔹 Immediately hide bonuses on packages
      _hideBonusesIfNotFirstRecharge();
    } catch (e) {
      print("confirmPayment failed: $e");
      rethrow;
    } finally {
      isPaymentProcessing = false;
      if (!_disposed) notifyListeners();
    }
  }

  String _getCurrencySymbol(String code) {
    switch (code.toUpperCase()) {
      case "PHP":
        return "₱";
      case "USD":
      default:
        return "\$";
    }
  }
}
