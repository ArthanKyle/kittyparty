import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../../core/services/api/recharge_service.dart';
import '../../../core/services/api/topUp_service.dart';
import '../../../core/utils/user_provider.dart';
import '../model/recharge.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RechargeViewModel extends ChangeNotifier {
  final RechargeService _service = RechargeService();
  final UserProvider userProvider;
  late final TopUpService _topUpService;
  late final IO.Socket _socket;

  RechargeViewModel({required this.userProvider}) {
    _topUpService = TopUpService(baseUrl: dotenv.env['BASE_URL']!);
    _initSocket();
  }

  final List<RechargePackage> _basePackages = [
    RechargePackage(coins: 7000, bonus: 350, price: 58.00),
    RechargePackage(coins: 70000, bonus: 4200, price: 574.20),
    RechargePackage(coins: 350000, bonus: 26250, price: 2900.00),
    RechargePackage(coins: 560000, bonus: 44800, price: 4639.42),
    RechargePackage(coins: 700000, bonus: 56000, price: 5850.00),
  ];

  int? _selectedIndex;
  int? get selectedIndex => _selectedIndex;

  RechargePackage? get selectedPackage =>
      _selectedIndex != null ? packages[_selectedIndex!] : null;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _clientSecret;
  String? get clientSecret => _clientSecret;

  /// Dynamic getter for packages
  List<RechargePackage> get packages {
    final isFirstTimeRecharge = userProvider.currentUser?.isFirstTimeRecharge ?? false;
    if (isFirstTimeRecharge) {
      return _basePackages
          .map((pkg) => RechargePackage(
        coins: pkg.coins,
        bonus: pkg.bonus * 2,
        price: pkg.price,
      ))
          .toList();
    }
    return _basePackages;
  }

  void selectPackage(int index) {
    _selectedIndex = index;
    final selected = selectedPackage;
    if (selected != null) {
      print(
        "✅ Package Selected -> Coins: ${selected.coins}, "
            "Bonus: ${selected.bonus}, "
            "Price: ₱${selected.price}",
      );
    }
    notifyListeners();
  }


  /// Start Stripe Payment
  Future<bool> startPayment(String countryCode) async {
    if (selectedPackage == null || userProvider.currentUser == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final amount = (selectedPackage!.price * 100).toInt();
      final response = await _service.createPaymentIntent(
        amount: amount,
        countryCode: countryCode,
        currency: 'PHP',
        userId: userProvider.currentUser!.id,
      );

      _clientSecret = response?['clientSecret'];

      if (_clientSecret != null) {
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: _clientSecret!,
            merchantDisplayName: 'KittyParty',
            style: ThemeMode.light,
          ),
        );

        // Present sheet and wait for actual result
        await Stripe.instance.presentPaymentSheet();

        // If it reaches here → payment was successful
        await performTopUp();
        return true;
      }
    } on StripeException catch (e) {
      print("Stripe payment canceled/failed: $e");
      return false;
    } catch (e) {
      print("Payment error: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }


  /// Perform top-up and update coins
  Future<bool> performTopUp() async {
    if (selectedPackage == null || userProvider.currentUser == null) return false;

    try {
      final userId = userProvider.currentUser!.id;
      final coinsToCredit = selectedPackage!.coins + selectedPackage!.bonus;
      final amount = selectedPackage!.price;

      final result = await _topUpService.createTopUp(
        userId: userId,
        providerId: null,
        amount: amount,
        coinsCredited: coinsToCredit.toInt(),
      );

      if (result != null && result['newBalance'] != null) {
        userProvider.currentUser!.coins = result['newBalance'];
        userProvider.currentUser!.isFirstTimeRecharge = false;
        userProvider.notifyListeners();
        return true;
      }
    } catch (e) {
      print("TopUp failed: $e");
    }
    return false;
  }

  /// Initialize socket.io connection to listen for live coin updates
  void _initSocket() {
    _socket = IO.io(dotenv.env['BASE_URL']!, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    final userId = userProvider.currentUser?.id;
    if (userId != null) {
      _socket.onConnect((_) {
        print('Socket connected');
        _socket.emit('join', userId);
      });

      _socket.on('coin_update', (data) {
        if (data['coins'] != null) {
          userProvider.currentUser!.coins = data['coins'];
          userProvider.notifyListeners();
        }
      });
    }

    _socket.onDisconnect((_) => print('Socket disconnected'));
  }

  @override
  void dispose() {
    _socket.dispose();
    super.dispose();
  }
}
