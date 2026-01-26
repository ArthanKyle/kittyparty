import 'dart:developer' as dev;

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
        countryCode: user.countryCode,
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

    // 🔍 LOG: input state
    dev.log(
      "🟡 [Recharge] Creating PaymentIntent",
      name: "Recharge",
      error: {
        "userIdentification": user.userIdentification,
        "countryCode": user.countryCode,
        "coins": selectedPackage!.coins,
        "method": method ?? "card",
        "displayAmount": displayAmount,
        "displaySymbol": displaySymbol,
      },
    );

    try {
      // 🔍 LOG: before API call
      dev.log(
        "📡 [Recharge] Calling createPaymentIntent API",
        name: "Recharge",
      );

      final json = await rechargeService.createPaymentIntent(
        userIdentification: user.userIdentification,
        countryCode: user.countryCode.isNotEmpty ? user.countryCode : "PH",
        method: method,
        coins: selectedPackage!.coins,
      );

      // 🔍 LOG: raw backend response
      dev.log(
        "🟢 [Recharge] PaymentIntent API response",
        name: "Recharge",
        error: json,
      );

      final clientSecret = json['clientSecret'] as String?;
      final transactionId = json['transactionId'] as String?;
      final display = json['display'] as Map<String, dynamic>?;

      // 🔍 LOG: parsed values
      dev.log(
        "🔐 [Recharge] Parsed PaymentIntent values",
        name: "Recharge",
        error: {
          "clientSecret": clientSecret != null ? "RECEIVED" : "NULL",
          "transactionId": transactionId,
          "display": display,
        },
      );

      if (clientSecret == null || transactionId == null) {
        dev.log(
          "❌ [Recharge] Missing clientSecret or transactionId",
          name: "Recharge",
        );
        return null;
      }

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
    } catch (e, stack) {
      // 🔥 LOG: exception
      dev.log(
        "🔥 [Recharge] createPaymentIntent FAILED",
        name: "Recharge",
        error: e,
        stackTrace: stack,
      );
      rethrow;
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

        // 🔑 GOOGLE PAY CONFIG
        googlePay: const PaymentSheetGooglePay(
          merchantCountryCode: "US", // IMPORTANT
          currencyCode: "USD",       // MUST MATCH STRIPE
          testEnv: true,             // false in production
        ),
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
      final json = await rechargeService.confirmPayment(
        transactionId: transactionId,
      );

      // ✅ 1. Wallet balance MUST come from newBalance
      final int newBalance = json['newBalance'] as int;
      userProvider.updateCoins(newBalance);

      // ✅ 2. VIP (THIS WAS COMPLETELY MISSING)
      final vip = json['vip'];
      final vipProgress = json['vipProgress'];

      if (vip != null) {
        userProvider.updateVip(
          vipLevel: vip['vipLevel'],
          vipCode: vip['vipCode'],
          vipTitle: vip['vipTitle'],
          vipPerks: List<String>.from(vip['vipPerks'] ?? []),
          vipTotalRechargeAmount:
          (vip['vipTotalRechargeAmount'] as num?)?.toDouble() ?? 0,
          vipLastUpdatedAt: vip['vipLastUpdatedAt'],
          vipConquerorEntryPermit:
          vip['vipConquerorEntryPermit'] == true,
          vipKingsOfKingsEntryTicket:
          vip['vipKingsOfKingsEntryTicket'] == true,
        );
      }

      if (vipProgress != null) {
        userProvider.updateVipProgress(vipProgress);
      }

      // ✅ 3. First-time recharge flag
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

extension on TransactionModel {
  operator [](String other) {}
}
