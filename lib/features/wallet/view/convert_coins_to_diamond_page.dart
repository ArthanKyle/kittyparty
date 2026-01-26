import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:kittyparty/core/global_widgets/dialogs/dialog_loading.dart';
import 'package:kittyparty/core/global_widgets/dialogs/dialog_info.dart';

import '../../../core/constants/colors.dart';
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
  int previewDiamonds = 0;

  // ✅ Documented rate: 1000 coins = 800 diamonds
  static const int minCoins = 1000;

  int _calculateDiamonds(int coins) {
    return (coins * 800) ~/ 1000;
  }

  @override
  Widget build(BuildContext context) {
    final walletVM = context.watch<WalletViewModel>();
    final currentCoins = walletVM.coins;

    final canConvert =
        coinsToConvert >= minCoins && coinsToConvert <= currentCoins;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const ConvertDiamondsAppBar(),

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
                        hintText: "Enter coins (min 1000)",
                      ),
                      onChanged: (value) {
                        final parsed = int.tryParse(value) ?? 0;
                        setState(() {
                          coinsToConvert = parsed;
                          previewDiamonds =
                          parsed >= minCoins ? _calculateDiamonds(parsed) : 0;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Text(
                      "$previewDiamonds diamonds",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  Center(
                    child: ElevatedButton(
                      onPressed: canConvert
                          ? () async {
                        DialogLoading(
                            subtext: "Processing conversion...")
                            .build(context);

                        try {
                          await walletVM
                              .convertCoinsToDiamonds(coinsToConvert);

                          Navigator.of(context).pop();

                          _coinController.clear();
                          setState(() {
                            coinsToConvert = 0;
                            previewDiamonds = 0;
                          });

                          DialogInfo(
                            headerText: "Conversion Successful",
                            subText:
                            "Your wallet has been updated successfully.",
                            confirmText: "OK",
                            onConfirm: () =>
                                Navigator.of(context).pop(),
                            onCancel: () =>
                                Navigator.of(context).pop(),
                          ).build(context);
                        } catch (e) {
                          Navigator.of(context).pop();

                          DialogInfo(
                            headerText: "Conversion Failed",
                            subText: e.toString(),
                            confirmText: "OK",
                            onConfirm: () =>
                                Navigator.of(context).pop(),
                            onCancel: () =>
                                Navigator.of(context).pop(),
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
