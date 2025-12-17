import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../wallet/viewmodel/wallet_viewmodel.dart';
import '../wallet_widgets/diamond_card.dart';
import '../wallet_widgets/convert_button.dart';
import 'convert_coins_to_diamond_page.dart';


class DiamondsPage extends StatelessWidget {
  const DiamondsPage({super.key});

  void _onConvert(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ConvertCoinsPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final walletVM = context.watch<WalletViewModel>();

    return Column(
      children: [
        DiamondCard(
          balance: walletVM.diamonds,
          onConvert: () => _onConvert(context),
        ),
        const SizedBox(height: 35),
        ConvertButton(
          onPressed: () => _onConvert(context),
        ),
        const Spacer(),
      ],
    );
  }
}
