import 'package:flutter/material.dart';
import 'package:kittyparty/core/utils/index_provider.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/global_widgets/buttons/recharge_button.dart';
import '../../../core/global_widgets/dialogs/dialog_info.dart';
import '../../../core/global_widgets/dialogs/dialog_loading.dart';
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

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => RechargeViewModel(userProvider: userProvider),
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
                builder: (context, walletVM, _) {
                  return CoinCard(balance: walletVM.wallet.coins);
                },
              ),

              // Packages Grid
              Consumer<RechargeViewModel>(
                builder: (context, viewModel, _) {
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
                        final isSelected = viewModel.selectedIndex == index;

                        return GestureDetector(
                          onTap: () => viewModel.selectPackage(index),
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
                                    Positioned(
                                      top: 0,
                                      right: 0,
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
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Text("${pkg.coins} coins",
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                                const SizedBox(height: 5),
                                Text("₱${pkg.price.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                        fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
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
                      enabled: viewModel.selectedPackage != null,
                      onPressed: () async {
                        if (viewModel.selectedPackage == null) return;

                        // Show loading dialog
                        DialogLoading(subtext: "Processing...").build(context);

                        await viewModel.startPayment("PH");

                        // Close loading dialog
                        Navigator.of(context, rootNavigator: true).pop();

                        // Success/Fail dialog
                        final success = viewModel.clientSecret != null;
                        DialogInfo(
                          headerText: success ? "Top Up Successful" : "Top Up Failed",
                          subText: success
                              ? "Your coins have been updated to ${viewModel.userProvider.currentUser?.coins}."
                              : "Payment was not completed.",
                          confirmText: "OK",
                          onConfirm: () => changePage(index: 4, context: context),
                          onCancel: () => Navigator.of(context, rootNavigator: true).pop(),
                        ).build(context);
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
