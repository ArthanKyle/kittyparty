import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/api/socket_service.dart';
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
            // 💎 Display current diamond balance
            DiamondCard(
              balance: diamondVM.diamond.diamonds,
              onConvert: () {
                final socketService = SocketService();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ConvertCoinsPage(socketService: socketService),
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
