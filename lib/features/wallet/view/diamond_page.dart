import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/diamond_viewmodel.dart';
import '../wallet_widgets/diamond_card.dart';
import 'convert_diamond_page.dart';
import '../wallet_widgets/convert_button.dart';

class DiamondsPage extends StatelessWidget {
  const DiamondsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DiamondViewModel>(
      builder: (context, diamondVM, _) {
        return Column(
          children: [
            DiamondCard(
              balance: diamondVM.diamond.diamonds,
              onConvert: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ConvertCoinsPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            ConvertButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ConvertCoinsPage(),
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
