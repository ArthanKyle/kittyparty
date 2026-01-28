import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:kittyparty/core/global_widgets/dialogs/dialog_loading.dart';
import 'package:kittyparty/core/global_widgets/dialogs/dialog_info.dart';
import 'package:kittyparty/core/constants/colors.dart';

import '../../wallet/viewmodel/wallet_viewmodel.dart';
import '../wallet_widgets/wallet_diamond_appbar.dart';
import '../wallet_widgets/diamond_card.dart';

class ConvertDiamondsPage extends StatefulWidget {
  const ConvertDiamondsPage({super.key});

  @override
  State<ConvertDiamondsPage> createState() => _ConvertDiamondsPageState();
}

class _ConvertDiamondsPageState extends State<ConvertDiamondsPage> {
  final TextEditingController _diamondController = TextEditingController();

  int diamondsToConvert = 0;
  int previewCoins = 0;

  static const int DIAMONDS_PER_COIN = 130;

  int _calculateCoins(int diamonds) {
    return diamonds ~/ DIAMONDS_PER_COIN;
  }

  @override
  Widget build(BuildContext context) {
    final walletVM = context.watch<WalletViewModel>();
    final currentDiamonds = walletVM.diamonds;

    final canConvert =
        diamondsToConvert > 0 &&
            diamondsToConvert <= currentDiamonds &&
            previewCoins > 0;

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
                    balance: currentDiamonds,
                    onConvert: () {},
                  ),

                  const SizedBox(height: 20),

                  Text(
                    "My Diamonds: $currentDiamonds",
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
                      controller: _diamondController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Enter diamonds to convert",
                      ),
                      onChanged: (value) {
                        final parsed = int.tryParse(value) ?? 0;
                        setState(() {
                          diamondsToConvert = parsed;
                          previewCoins =
                          parsed > 0 ? _calculateCoins(parsed) : 0;
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
                      "Coins equivalent: ~$previewCoins",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "⚠️ Very low return exchange\n130 diamonds = 1 coin",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),

                  const SizedBox(height: 30),

                  Center(
                    child: ElevatedButton(
                      onPressed: canConvert
                          ? () async {
                        DialogLoading(
                          subtext: "Processing exchange...",
                        ).build(context);

                        try {
                          await walletVM.convertDiamondsToCoins(
                            diamondsToConvert,
                          );

                          Navigator.of(context).pop();

                          _diamondController.clear();
                          setState(() {
                            diamondsToConvert = 0;
                            previewCoins = 0;
                          });

                          DialogInfo(
                            headerText: "Exchange Successful",
                            subText:
                            "Diamonds have been converted to coins.",
                            confirmText: "OK",
                            onConfirm: () =>
                                Navigator.of(context).pop(),
                            onCancel: () =>
                                Navigator.of(context).pop(),
                          ).build(context);
                        } catch (e) {
                          Navigator.of(context).pop();

                          DialogInfo(
                            headerText: "Exchange Failed",
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
