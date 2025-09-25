import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/user_provider.dart';
import '../../wallet/viewmodel/wallet_viewmodel.dart';
import '../wallet_widgets/wallet_diamond_appbar.dart';

class ConvertCoinsPage extends StatefulWidget {
  const ConvertCoinsPage({super.key});

  @override
  State<ConvertCoinsPage> createState() => _ConvertCoinsPageState();
}

class _ConvertCoinsPageState extends State<ConvertCoinsPage> {
  final TextEditingController _coinController = TextEditingController();

  int coinsToConvert = 0;
  int diamonds = 0;

  // 1 coin = 1000 diamonds
  static const int coinToDiamondRate = 1000;

  @override
  Widget build(BuildContext context) {
    final walletVM = Provider.of<WalletViewModel>(context);
    int currentCoins = walletVM.wallet.coins;

    return Scaffold(
      body: Column(
        children: [
          const ConvertDiamondsAppBar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("My Coins: $currentCoins",
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 10),

                  // Coins input
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _coinController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Enter coins...",
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(
                            "assets/icons/KPcoin.png",
                            height: 24,
                            width: 24,
                            fit: BoxFit.contain,
                          ),
                        ),
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

                  // Show diamond conversion inside a styled "textbox"
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200, width: 1),
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          "assets/icons/jewel.PNG", // <-- replace with your diamond asset
                          height: 20,
                          width: 20,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "$diamonds diamonds",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.blue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),


                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(14),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "Conversion Rule:\n1 coin = 1000 diamonds",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: (coinsToConvert > 0 &&
                        coinsToConvert <= currentCoins)
                        ? () {
                      final updatedCoins =
                          currentCoins - coinsToConvert;
                      walletVM.updateCoins(updatedCoins);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Exchanged $coinsToConvert coins "
                                "for $diamonds diamonds!",
                          ),
                        ),
                      );

                      setState(() {
                        coinsToConvert = 0;
                        diamonds = 0;
                        _coinController.clear();
                      });
                    }
                        : null,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      backgroundColor: Colors.blue.shade300,
                    ),
                    child: const Text("Confirm Exchange",
                      style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),),
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
