import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import '../../../core/services/api/recharge_service.dart';
import '../../../core/utils/user_provider.dart';
import '../model/recharge.dart';
import '../model/transaction.dart';

class RechargeViewModel extends ChangeNotifier {
  final UserProvider userProvider;
  final RechargeService rechargeService;

  RechargeViewModel({
    required this.userProvider,
    required this.rechargeService,
  });

  List<RechargePackage> packages = [];
  RechargePackage? selectedPackage;
  bool isLoading = false;
  bool isPaymentProcessing = false;

  // Display info for local currency
  double displayAmount = 0.0;
  String displayCurrency = "USD";
  String displaySymbol = "\$";

  /// Fetch packages dynamically
  Future<void> fetchPackages() async {
    final user = userProvider.currentUser;
    if (user == null) {
      print("fetchPackages: no user logged in");
      return;
    }

    print("fetchPackages: fetching packages for user ${user.id}");
    isLoading = true;
    notifyListeners();

    try {
      final response = await rechargeService.fetchPackages(user.id);
      print("fetchPackages: received ${response.length} packages");
      packages = response;

      if (packages.isNotEmpty) selectedPackage ??= packages.first;

      displayAmount = selectedPackage!.price;
      displayCurrency = user.countryCode.toUpperCase();
      displaySymbol = _getCurrencySymbol(displayCurrency);
      print("fetchPackages: selected package ${selectedPackage!.coins} coins, price $displayAmount $displayCurrency");
    } catch (e) {
      print("fetchPackages failed: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Select a package
  void selectPackage(RechargePackage pkg) {
    selectedPackage = pkg;
    displayAmount = pkg.price;
    displayCurrency = userProvider.currentUser?.countryCode.toUpperCase() ?? "USD";
    displaySymbol = _getCurrencySymbol(displayCurrency);
    print("selectPackage: selected ${pkg.coins} coins, price $displayAmount $displayCurrency");
    notifyListeners();
  }

  /// Create a payment intent
  Future<TransactionModel?> createPaymentIntent({String? method}) async {
    final user = userProvider.currentUser;
    if (selectedPackage == null || user == null) {
      print("createPaymentIntent: no package selected or no user logged in");
      throw Exception("No package selected or user not logged in");
    }

    print("createPaymentIntent: creating payment intent for ${selectedPackage!.coins} coins, price ${selectedPackage!.price}");
    isPaymentProcessing = true;
    notifyListeners();

    try {
      final userId = user.id;
      final countryCode = user.countryCode.isNotEmpty ? user.countryCode : 'PH';

      final json = await rechargeService.createPaymentIntent(
        userId: userId,
        amount: selectedPackage!.price,
        countryCode: countryCode,
        method: method,
      );

      print("createPaymentIntent: response received $json");

      final clientSecret = json['clientSecret'] as String?;
      final transactionId = json['transactionId'] as String?;
      final display = json['display'] as Map<String, dynamic>?;

      if (clientSecret == null || transactionId == null) {
        print("createPaymentIntent: Missing clientSecret or transactionId in response");
        return null;
      }

      displayAmount = display?['amount']?.toDouble() ?? selectedPackage!.price;
      displayCurrency = (display?['currency'] ?? 'USD').toString().toUpperCase();
      displaySymbol = display?['symbol'] ?? _getCurrencySymbol(displayCurrency);

      print("createPaymentIntent: clientSecret=$clientSecret, transactionId=$transactionId, displayAmount=$displayAmount $displayCurrency");

      // Create a temporary TransactionModel to carry needed info
      final transaction = TransactionModel(
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

      return transaction;
    } catch (e, stack) {
      print("createPaymentIntent error: $e\n$stack");
      rethrow;
    } finally {
      isPaymentProcessing = false;
      notifyListeners();
      print("createPaymentIntent: finished processing");
    }
  }


  /// Present Stripe Payment Sheet
  Future<void> presentPaymentSheet({required String clientSecret}) async {
    print("presentPaymentSheet: starting with clientSecret $clientSecret");
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Kittyparty',
          style: ThemeMode.light,
        ),
      );
      await Stripe.instance.presentPaymentSheet();
      print("presentPaymentSheet: completed successfully");
    } catch (e) {
      print("presentPaymentSheet failed: $e");
      rethrow;
    }
  }

  //// Confirm payment and credit coins (use transactionId from backend)
  Future<void> confirmPayment(String transactionId) async {
    final user = userProvider.currentUser;
    if (user == null) return;

    print("confirmPayment: recording transaction $transactionId");
    isPaymentProcessing = true;
    notifyListeners();

    try {
      final topUp = await rechargeService.confirmPayment(transactionId: transactionId);
      final coinsFinal = topUp.coinsFinal;
      print("confirmPayment: transaction recorded, final coins $coinsFinal");

      userProvider.updateCoins(coinsFinal);
      print("confirmPayment: updated user's coins locally to ${user.coins}");
    } catch (e) {
      print("confirmPayment failed: $e");
      rethrow;
    } finally {
      isPaymentProcessing = false;
      notifyListeners();
      print("confirmPayment: finished processing");
    }
  }


  /// Helper to map currency code to symbol
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
