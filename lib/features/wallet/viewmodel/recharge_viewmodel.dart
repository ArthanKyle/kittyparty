import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import '../../../core/services/api/recharge_service.dart';
import '../../../core/utils/user_provider.dart';
import '../model/recharge.dart';

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

  /// Fetch packages dynamically
  Future<void> fetchPackages() async {
    final user = userProvider.currentUser;
    if (user == null) return;

    print("Fetching packages for user: ${user.id}");
    isLoading = true;
    notifyListeners();

    try {
      final response = await rechargeService.fetchPackages(user.id);

      // packages is already List<RechargePackage>
      packages = response;

      print("Fetched ${packages.length} packages");
      if (packages.isNotEmpty) selectedPackage ??= packages.first;
      print("Preselected package: ${selectedPackage?.coins} coins for ${selectedPackage?.price}");
    } catch (e) {
      print("Failed to fetch packages: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Select a package
  void selectPackage(RechargePackage pkg) {
    selectedPackage = pkg;
    notifyListeners();
    print("Selected package: ${pkg.coins} coins for ${pkg.price}");
  }

  /// Create a payment intent
  Future<Map<String, dynamic>> createPaymentIntent({String? method}) async {
    final user = userProvider.currentUser;
    if (selectedPackage == null || user == null) {
      throw Exception("No package selected or user not logged in");
    }

    isPaymentProcessing = true;
    notifyListeners();

    try {
      final userId = user.id;
      final countryCode = user.countryCode.isNotEmpty ? user.countryCode : 'PH';

      print("Creating payment intent with:");
      print("userId: $userId");
      print("amount: ${selectedPackage!.price}");
      print("countryCode: $countryCode");

      final data = await rechargeService.createPaymentIntent(
        userId: userId,
        amount: selectedPackage!.price,
        countryCode: countryCode,
        method: method,
      );
      print("Payment intent response: $data");
      return data;
    } finally {
      isPaymentProcessing = false;
      notifyListeners();
    }
  }

  /// Present Stripe Payment Sheet
  Future<void> presentPaymentSheet({required String clientSecret}) async {
    try {
      print("Initializing Stripe Payment Sheet with clientSecret: $clientSecret");
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Kittyparty',
          style: ThemeMode.light,
        ),
      );

      print("Presenting Stripe Payment Sheet...");
      await Stripe.instance.presentPaymentSheet();
      print("Payment Sheet completed successfully.");
    } catch (e) {
      print("Stripe Payment Sheet failed: $e");
      rethrow;
    }
  }

  /// Confirm payment and credit coins
  Future<void> confirmPayment(String paymentIntentId) async {
    final user = userProvider.currentUser;
    if (user == null) return;

    isPaymentProcessing = true;
    notifyListeners();

    try {
      print("Confirming payment with paymentIntentId: $paymentIntentId");
      final topUp = await rechargeService.confirmPayment(paymentIntentId: paymentIntentId);
      userProvider.updateCoins(topUp.coinsFinal);
      print("Payment confirmed. Coins updated: ${topUp.coinsFinal}");
    } catch (e) {
      print("Payment confirmation failed: $e");
      rethrow;
    } finally {
      isPaymentProcessing = false;
      notifyListeners();
    }
  }
}
