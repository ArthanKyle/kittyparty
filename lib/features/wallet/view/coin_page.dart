import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodel/wallet_viewmodel.dart';
import '../wallet_widgets/coin_card.dart';
import 'recharge.dart';
import '../wallet_widgets/recharge_button.dart';

class CoinsPage extends StatelessWidget {
  const CoinsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WalletViewModel>(
      builder: (context, walletVM, _) {
        return Column(
          children: [
            CoinCard(balance: walletVM.coins),
            const SizedBox(height: 20),
            RechargeButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RechargeScreen(),
                  ),
                );
              },
            ),
            const Spacer(),
          ],
        );
      },
    );
  }
}
