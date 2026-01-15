import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/colors.dart';
import '../../../core/global_widgets/buttons/recharge_button.dart';
import '../../../core/global_widgets/dialogs/dialog_info.dart';
import '../../../core/global_widgets/dialogs/dialog_loading.dart';
import '../../../core/services/api/recharge_service.dart';
import '../../../core/utils/user_provider.dart';
import '../../auth/widgets/arrow_back.dart';
import '../viewmodel/recharge_viewmodel.dart';
import '../viewmodel/wallet_viewmodel.dart';
import '../wallet_widgets/coin_card.dart';

class RechargeScreen extends StatelessWidget {
  const RechargeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.read<UserProvider>();
    final rechargeService = context.read<RechargeService>(); // ✅ FIX

    return ChangeNotifierProvider(
      create: (_) => RechargeViewModel(
        userProvider: userProvider,
        rechargeService: rechargeService,
      )..fetchPackages(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: ArrowBack(onTap: () => Navigator.pop(context)),
          title: const Text(
            "My Account",
            style: TextStyle(color: Colors.black),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),

              // 💰 Coins
              Consumer<WalletViewModel>(
                builder: (_, walletVM, __) =>
                    CoinCard(balance: walletVM.coins),
              ),

              // 📦 Packages
              Consumer<RechargeViewModel>(
                builder: (context, viewModel, _) {
                  if (viewModel.isLoading) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.all(12),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisExtent: 140,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: viewModel.packages.length,
                      itemBuilder: (_, index) {
                        final pkg = viewModel.packages[index];
                        final isSelected =
                            viewModel.selectedPackage == pkg;

                        return GestureDetector(
                          onTap: () => viewModel.selectPackage(pkg),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.blue.shade50
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.gold
                                    : Colors.grey.shade200,
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
                                Image.asset(
                                  "assets/icons/KPcoin.png",
                                  height: 64,
                                  width: 64,
                                ),
                                const SizedBox(height: 6),
                                Text("${pkg.coins} coins"),
                                const SizedBox(height: 4),
                                Text(
                                  "${pkg.symbol}${pkg.price.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),

              // 🔘 Recharge button
              Consumer<RechargeViewModel>(
                builder: (context, viewModel, _) {
                  return Padding(
                    padding: const EdgeInsets.all(8),
                    child: RechargeButton(
                      enabled: viewModel.selectedPackage != null &&
                          !viewModel.isPaymentProcessing,
                      onPressed: () async {
                        final pkg = viewModel.selectedPackage;
                        if (pkg == null) return;

                        DialogLoading(subtext: "Processing")
                            .build(context);

                        try {
                          final tx = await viewModel
                              .createPaymentIntent(method: "card");

                          if (tx?.clientSecret == null ||
                              tx?.id == null) {
                            throw Exception("Invalid transaction");
                          }

                          await viewModel.presentPaymentSheet(
                            clientSecret: tx!.clientSecret!,
                          );

                          await viewModel.confirmPayment(tx.id!);

                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }

                          DialogInfo(
                            headerText: "Top Up Successful",
                            subText:
                            "Your coins are now ${context.read<WalletViewModel>().coins}",
                            confirmText: "OK",
                            onConfirm: () => Navigator.pop(context),
                            onCancel: () => Navigator.pop(context),
                          ).build(context);
                        } catch (_) {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }

                          DialogInfo(
                            headerText: "Top Up Failed",
                            subText:
                            "The payment flow was cancelled.",
                            confirmText: "OK",
                            onConfirm: () => Navigator.pop(context),
                            onCancel: () => Navigator.pop(context),
                          ).build(context);
                        }
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
