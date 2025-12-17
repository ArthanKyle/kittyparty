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
import '../../wallet/viewmodel/wallet_viewmodel.dart';
import '../wallet_widgets/coin_card.dart';

class RechargeScreen extends StatelessWidget {
  const RechargeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.read<UserProvider>();
    final rechargeService = RechargeService();

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
          title: const Text("My Account"),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 10),

              // Coins
              Consumer<WalletViewModel>(
                builder: (_, walletVM, __) =>
                    CoinCard(balance: walletVM.coins),
              ),

              // Packages
              Consumer<RechargeViewModel>(
                builder: (context, viewModel, _) {
                  if (viewModel.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: viewModel.packages.length,
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisExtent: 140,
                    ),
                    itemBuilder: (_, index) {
                      final pkg = viewModel.packages[index];
                      return GestureDetector(
                        onTap: () => viewModel.selectPackage(pkg),
                        child: Text("${pkg.coins} coins"),
                      );
                    },
                  );
                },
              ),

              Consumer<RechargeViewModel>(
                builder: (context, viewModel, _) {
                  return RechargeButton(
                    enabled: viewModel.selectedPackage != null,
                    onPressed: () async {
                      DialogLoading(subtext: "Processing").build(context);

                      try {
                        final tx =
                        await viewModel.createPaymentIntent(method: "card");
                        await viewModel.presentPaymentSheet(
                          clientSecret: tx!.clientSecret!,
                        );
                        await viewModel.confirmPayment(tx.id!);

                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
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
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        }

                        DialogInfo(
                          headerText: "Top Up Failed",
                          subText: "The payment flow was cancelled.",
                          confirmText: "OK",
                          onConfirm: () => Navigator.pop(context),
                          onCancel: () => Navigator.pop(context),
                        ).build(context);
                      }
                    },
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
