import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/user_provider.dart';
import '../viewmodel/wallet_viewmodel.dart';
import '../wallet_widgets/wallet_appbar.dart';
import 'coin_page.dart';
import 'diamond_page.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final type =
    _tabController.index == 0 ? WalletType.coins : WalletType.diamonds;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            WalletAppBar(type: type, controller: _tabController),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  CoinsPage(),
                  DiamondsPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
