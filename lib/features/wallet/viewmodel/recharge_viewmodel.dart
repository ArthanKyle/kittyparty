import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import '../../../core/services/api/recharge_service.dart';
import '../../../core/utils/user_provider.dart';
import '../model/recharge.dart';
import '../model/transaction.dart';

class RechargeViewModel extends ChangeNotifier {
  final UserProvider userProvider;
  final RechargeService rechargeService;

  bool _disposed = false;

  RechargeViewModel({
    required this.rechargeService,
    required this.userProvider,
  });

  List<RechargePackage> packages = [];
  RechargePackage? selectedPackage;

  bool isLoading = false;
  bool isPaymentProcessing = false;

  double displayAmount = 0.0;
  String displaySymbol = "₱";

  /* =============================
     FETCH PACKAGES
  ============================== */
  Future<void> fetchPackages() async {
    final user = userProvider.currentUser;
    if (user == null) return;

    isLoading = true;
    if (!_disposed) notifyListeners();

    try {
      packages = await rechargeService.fetchPackages(
        user.userIdentification,
      );

      if (!user.isFirstTimeRecharge) {
        _hideBonusesIfNotFirstRecharge();
      }

      if (packages.isNotEmpty) {
        selectPackage(packages.first);
      }
    } finally {
      isLoading = false;
      if (!_disposed) notifyListeners();
    }
  }

  /* =============================
     SELECT PACKAGE
  ============================== */
  void selectPackage(RechargePackage pkg) {
    selectedPackage = pkg;
    displayAmount = pkg.price;
    displaySymbol = pkg.symbol;
    if (!_disposed) notifyListeners();
  }

  /* =============================
     CREATE PAYMENT INTENT
  ============================== */
  Future<TransactionModel?> createPaymentIntent({String? method}) async {
    final user = userProvider.currentUser;
    if (user == null || selectedPackage == null) {
      throw Exception("No user or package selected");
    }

    isPaymentProcessing = true;
    if (!_disposed) notifyListeners();

    try {
      final json = await rechargeService.createPaymentIntent(
        userIdentification: user.userIdentification,
        amount: selectedPackage!.price,
        countryCode:
        user.countryCode.isNotEmpty ? user.countryCode : "PH",
        method: method,
        coins: selectedPackage!.coins,
      );

      final clientSecret = json['clientSecret'] as String?;
      final transactionId = json['transactionId'] as String?;
      final display = json['display'] as Map<String, dynamic>?;

      if (clientSecret == null || transactionId == null) return null;

      displayAmount =
          (display?['amount'] as num?)?.toDouble() ?? displayAmount;
      displaySymbol = display?['symbol'] ?? displaySymbol;

      return TransactionModel(
        id: transactionId,
        userIdentification: user.userIdentification,
        paymentIntentId: null,
        clientSecret: clientSecret,
        paymentMethod: method ?? 'card',
        status: 'pending',
        amount: displayAmount,
        currency: "",
        coinsBase: selectedPackage!.coins,
        coinsBonus: 0,
        coinsFinal: selectedPackage!.coins,
        transactionRef: '',
        providerId: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } finally {
      isPaymentProcessing = false;
      if (!_disposed) notifyListeners();
    }
  }

  /* =============================
     STRIPE PAYMENT SHEET
  ============================== */
  Future<void> presentPaymentSheet({
    required String clientSecret,
  }) async {
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: 'Kittyparty',
        style: ThemeMode.light,
      ),
    );

    await Stripe.instance.presentPaymentSheet();
  }

  /* =============================
     CONFIRM PAYMENT
  ============================== */
  Future<void> confirmPayment(String transactionId) async {
    final user = userProvider.currentUser;
    if (user == null) return;

    isPaymentProcessing = true;
    if (!_disposed) notifyListeners();

    try {
      final topUp = await rechargeService.confirmPayment(
        transactionId: transactionId,
      );

      userProvider.updateCoins(topUp.coinsFinal);

      if (user.isFirstTimeRecharge) {
        user.isFirstTimeRecharge = false;
        _hideBonusesIfNotFirstRecharge();
      }
    } finally {
      isPaymentProcessing = false;
      if (!_disposed) notifyListeners();
    }
  }

  /* =============================
     HELPERS
  ============================== */
  void _hideBonusesIfNotFirstRecharge() {
    packages = packages
        .map(
          (pkg) => RechargePackage(
        coins: pkg.coins,
        bonus: 0,
        price: pkg.price,
        symbol: pkg.symbol,
        currency: pkg.currency,
      ),
    )
        .toList();
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
