import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/global_widgets/buttons/recharge_button.dart';
import '../../../core/global_widgets/dialogs/dialog_info.dart';
import '../../../core/global_widgets/dialogs/dialog_loading.dart';
import '../../../core/services/api/recharge_service.dart';
import '../../../core/services/api/socket_service.dart';
import '../../../core/utils/user_provider.dart';
import '../../auth/widgets/arrow_back.dart';
import '../viewmodel/recharge_viewmodel.dart';
import '../viewmodel/wallet_viewmodel.dart';
import '../wallet_widgets/coin_card.dart';

class RechargeScreen extends StatelessWidget {
  final SocketService socketService;

  const RechargeScreen({super.key, required this.socketService});


  @override
  Widget build(BuildContext context) {
    final userProvider = context.read<UserProvider>();
    final rechargeService = RechargeService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => RechargeViewModel(
            userProvider: userProvider,
            rechargeService: rechargeService,
            socketService: socketService,
          )..fetchPackages(),
        ),
        ChangeNotifierProvider(
          create: (_) => WalletViewModel(userProvider: userProvider),
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: ArrowBack(onTap: () => Navigator.pop(context)),
          title: const Text("My Account", style: TextStyle(color: Colors.black)),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),

              // My Coins Section
              Consumer<WalletViewModel>(
                builder: (context, walletVM, _) => CoinCard(balance: walletVM.wallet.coins),
              ),

              // Packages Grid
              Consumer<RechargeViewModel>(
                builder: (context, viewModel, _) {
                  if (viewModel.isLoading) return const Center(child: CircularProgressIndicator());

                  return Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisExtent: 140,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: viewModel.packages.length,
                      itemBuilder: (context, index) {
                        final pkg = viewModel.packages[index];
                        final isSelected = viewModel.selectedPackage == pkg;

                        return GestureDetector(
                          onTap: () => viewModel.selectPackage(pkg),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.blue.shade50 : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? AppColors.gold : Colors.grey.shade200,
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(1, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Stack(
                                  alignment: Alignment.topRight,
                                  children: [
                                    Image.asset(
                                      "assets/icons/KPcoin.png",
                                      height: 64,
                                      width: 64,
                                      fit: BoxFit.contain,
                                    ),
                                    if (pkg.bonus > 0)
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: AnimatedOpacity(
                                          duration: const Duration(milliseconds: 300),
                                          opacity: pkg.bonus > 0 ? 1.0 : 0.0,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.orange.shade200,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              "+ ${pkg.bonus}",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.orange.shade800,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "${pkg.coins} coins",
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 5),
                                // ✅ Fixed: Use pkg.price, pkg.symbol instead of global displayAmount
                                Text(
                                  "${pkg.symbol}${pkg.price.toStringAsFixed(2)} ${viewModel.displayCurrency}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )

                  );
                },
              ),

              // Agreement Section
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Read and agree to ", style: TextStyle(fontSize: 12, color: Colors.black54)),
                    GestureDetector(
                      onTap: () {},
                      child: const Text(
                        "User Recharge Agreement",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Recharge Button
              Consumer<RechargeViewModel>(
                builder: (context, viewModel, _) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
                    child: RechargeButton(
                      enabled: viewModel.selectedPackage != null && !viewModel.isPaymentProcessing,
                      onPressed: () async {
                        final pkg = viewModel.selectedPackage;
                        if (pkg == null) return;

                        print("Recharge button pressed for package: ${pkg.coins} coins");

                        final loadingDialog = DialogLoading(subtext: "Processing...");
                        unawaited(loadingDialog.build(context));
                        print("Loading dialog shown");

                        try {
                          print("Creating payment intent...");
                          final transaction = await viewModel.createPaymentIntent(method: "card");

                          final clientSecret = transaction?.clientSecret;
                          final transactionId = transaction?.id;

                          print("Payment intent created: clientSecret=$clientSecret, id=$transactionId");

                          if (clientSecret == null || transactionId == null || transactionId.isEmpty) {
                            throw Exception("Payment data is missing");
                          }

                          print("Presenting Stripe Payment Sheet...");
                          await viewModel.presentPaymentSheet(clientSecret: clientSecret);
                          print("Stripe Payment Sheet presented");

                          print("Confirming payment with transactionId=$transactionId...");
                          await viewModel.confirmPayment(transactionId);
                          print("Payment confirmed, coins updated: ${viewModel.userProvider.currentUser?.coins}");

                          if (Navigator.of(context).canPop()) Navigator.of(context).pop();
                          print("Loading dialog closed");

                          DialogInfo(
                            headerText: "Top Up Successful",
                            subText: "Your coins have been updated to ${viewModel.userProvider.currentUser?.coins}.",
                            confirmText: "OK",
                            onConfirm: () => Navigator.pop(context),
                            onCancel: () => Navigator.pop(context),
                          ).build(context);
                          print("Success dialog shown");

                        } catch (e, stack) {
                          print("Recharge failed: $e\n$stack");

                          if (Navigator.of(context).canPop()) Navigator.of(context).pop();
                          print("Loading dialog closed due to error");

                          DialogInfo(
                            headerText: "Top Up Failed",
                            subText: "The payment flow has been canceled",
                            confirmText: "OK",
                            onConfirm: () => Navigator.pop(context),
                            onCancel: () => Navigator.pop(context),
                          ).build(context);
                          print("Error dialog shown: $e");
                        }
                      },
                    ),
                  );
                },
              )

            ],
          ),
        ),
      ),
    );
  }
}
