import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:kittyparty/core/global_widgets/dialogs/dialog_loading.dart';
import 'package:kittyparty/core/global_widgets/dialogs/dialog_info.dart';

import '../../../core/constants/colors.dart';
import '../../../core/utils/user_provider.dart';
import '../../wallet/viewmodel/wallet_viewmodel.dart';
import '../wallet_widgets/wallet_diamond_appbar.dart';
import '../wallet_widgets/diamond_card.dart';

class ConvertCoinsPage extends StatefulWidget {
  const ConvertCoinsPage({super.key});

  @override
  State<ConvertCoinsPage> createState() => _ConvertCoinsPageState();
}

class _ConvertCoinsPageState extends State<ConvertCoinsPage> {
  final TextEditingController _coinController = TextEditingController();
  int coinsToConvert = 0;
  int diamonds = 0;

  static const int coinToDiamondRate = 1000;

  @override
  Widget build(BuildContext context) {
    final walletVM = context.watch<WalletViewModel>();
    final int currentCoins = walletVM.coins;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          /// ✅ FIXED APP BAR (non-scrollable)
          const ConvertDiamondsAppBar(),

          /// ✅ SCROLLABLE CONTENT
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DiamondCard(
                    balance: walletVM.diamonds,
                    onConvert: () {},
                  ),

                  const SizedBox(height: 20),

                  Text(
                    "My Coins: $currentCoins",
                    style: const TextStyle(fontSize: 16),
                  ),

                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _coinController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Enter coins...",
                      ),
                      onChanged: (value) {
                        setState(() {
                          coinsToConvert = int.tryParse(value) ?? 0;
                          diamonds = coinsToConvert * coinToDiamondRate;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Text(
                      "$diamonds diamonds",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
              Center(
                  child: ElevatedButton(
                    onPressed: (coinsToConvert > 0 &&
                        coinsToConvert <= currentCoins)
                        ? () async {
                      DialogLoading(subtext: "Processing").build(context);

                      try {
                        await walletVM
                            .convertCoinsToDiamonds(coinsToConvert);

                        Navigator.of(context).pop();

                        _coinController.clear();
                        setState(() {
                          coinsToConvert = 0;
                          diamonds = 0;
                        });

                        DialogInfo(
                          headerText: "Conversion Successful",
                          subText:
                          "Your diamonds are now ${walletVM.diamonds}.",
                          confirmText: "OK",
                          onConfirm: () => Navigator.pop(context),
                          onCancel: () => Navigator.pop(context),
                        ).build(context);
                      } catch (_) {
                        Navigator.of(context).pop();

                        DialogInfo(
                          headerText: "Conversion Failed",
                          subText:
                          "Unable to complete the exchange. Please try again.",
                          confirmText: "OK",
                          onConfirm: () => Navigator.pop(context),
                          onCancel: () => Navigator.pop(context),
                        ).build(context);
                      }
                    }
                        : null,
                    child: const Text(
                      "Confirm Exchange",
                      style: TextStyle(color: AppColors.accentWhite),
                    ),
                  ),
                ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
