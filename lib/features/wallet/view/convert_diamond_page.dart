import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kittyparty/core/global_widgets/dialogs/dialog_loading.dart';
import 'package:kittyparty/core/global_widgets/dialogs/dialog_info.dart';
import '../../../core/services/api/socket_service.dart';
import '../../../core/utils/user_provider.dart';
import '../../wallet/viewmodel/wallet_viewmodel.dart';
import '../viewmodel/diamond_viewmodel.dart';
import '../wallet_widgets/wallet_diamond_appbar.dart';
import '../wallet_widgets/diamond_card.dart';

class ConvertCoinsPage extends StatefulWidget {
  final SocketService socketService;
  const ConvertCoinsPage({super.key, required this.socketService});

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
    final walletVM = Provider.of<WalletViewModel>(context, listen: true);
    final diamondVM = Provider.of<DiamondViewModel>(context, listen: true);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final int currentCoins = walletVM.wallet.coins;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const ConvertDiamondsAppBar(),
            const SizedBox(height: 10),


            DiamondCard(
              balance: diamondVM.diamond.diamonds,
              onConvert: () {},
            ),

            const SizedBox(height: 20),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "My Coins: $currentCoins",
                style: const TextStyle(fontSize: 16),
              ),
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
                    "assets/icons/jewel.PNG",
                    height: 20,
                    width: 20,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "$diamonds diamonds",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
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
                  coinsToConvert <= currentCoins &&
                  !diamondVM.isConverting)
                  ? () async {
                DialogLoading(subtext: "Processing").build(context);

                try {
                  await diamondVM.convertCoinsToDiamonds(coinsToConvert);

                  if (Navigator.of(context).canPop()) Navigator.of(context).pop();

                  _coinController.clear();
                  setState(() {
                    coinsToConvert = 0;
                    diamonds = 0;
                  });

                  DialogInfo(
                    headerText: "Conversion Successful",
                    subText:
                    "Your diamonds have been updated to ${userProvider.currentUser?.diamonds}.",
                    confirmText: "OK",
                    onConfirm: () => Navigator.pop(context),
                    onCancel: () => Navigator.pop(context),
                  ).build(context);

                  print("✅ Conversion successful dialog shown");
                } catch (e, stack) {
                  print("❌ Conversion failed: $e\n$stack");

                  if (Navigator.of(context).canPop()) Navigator.of(context).pop();

                  DialogInfo(
                    headerText: "Conversion Failed",
                    subText: "Unable to complete the exchange. Please try again.",
                    confirmText: "OK",
                    onConfirm: () => Navigator.pop(context),
                    onCancel: () => Navigator.pop(context),
                  ).build(context);
                }
              }
                  : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                backgroundColor: Colors.blue.shade300,
              ),
              child: diamondVM.isConverting
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
                  : const Text(
                "Confirm Exchange",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
