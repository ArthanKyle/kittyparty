import 'package:flutter/material.dart';
import 'package:kittyparty/app.dart';
import 'package:provider/provider.dart';
import '../viewmodel/wallet_viewmodel.dart';
import '../wallet_widgets/diamond_card.dart';
import '../wallet_widgets/convert_button.dart';

class DiamondsPage extends StatelessWidget {
  const DiamondsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WalletViewModel>(
      builder: (context, walletVM, _) {
        // 🔍 DEBUG
        print("💎 UI diamonds = ${walletVM.diamonds}");

        return Column(
          children: [
            DiamondCard(
              balance: walletVM.diamonds, // ✅ LIVE SOURCE
              onConvert: () {},
            ),
            const SizedBox(height: 35),
            ConvertButton(
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.diamond);
              },
            ),
            const Spacer(),
          ],
        );
      },
    );
  }
}
