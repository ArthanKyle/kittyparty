import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/api/socket_service.dart';
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
            CoinCard(balance: walletVM.wallet.coins),
            const SizedBox(height: 20),
            RechargeButton(
              onPressed: () {
                final socketService = SocketService(); // local instance
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RechargeScreen(socketService: socketService),
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
