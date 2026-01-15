import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/user_provider.dart';
import '../../landing/model/gift_transaction.dart';
import '../../landing/viewmodel/transaction_viewmodel.dart';
import '../../wallet/model/transaction.dart';

class TransactionPage extends StatefulWidget {
  final String? roomId;

  const TransactionPage({
    super.key,
    this.roomId,
  });

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  /* =============================
     REFRESH HANDLER
  ============================== */
  Future<void> _onRefresh(TransactionViewModel vm) async {
    final user = context.read<UserProvider>().currentUser;
    if (user == null) return;

    switch (vm.activeTab) {
      case TransactionTab.gifts:
        await vm.loadGifts(user.userIdentification);
        break;
      case TransactionTab.recharges:
        await vm.loadRecharges(user.userIdentification);
        break;
      case TransactionTab.roomIncome:
        if (widget.roomId != null) {
          await vm.loadRoomIncome(widget.roomId!);
        }
        break;
    }
  }

  /* =============================
     INIT
  ============================== */
  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<UserProvider>().currentUser;
      if (user != null) {
        context
            .read<TransactionViewModel>()
            .loadGifts(user.userIdentification);
      }
    });

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) return;

      final user = context.read<UserProvider>().currentUser;
      if (user == null) return;

      final vm = context.read<TransactionViewModel>();

      vm.setTab(
        tab: TransactionTab.values[_tabController.index],
        userIdentification: user.userIdentification,
        roomId: widget.roomId,
      );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /* =============================
     BUILD
  ============================== */
  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionViewModel>(
      builder: (_, vm, __) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Transactions"),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: "Gifts"),
                Tab(text: "Recharges"),
                Tab(text: "Room Income"),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _scrollTab(vm, _giftContent(vm)),
              _scrollTab(vm, _rechargeContent(vm)),
              _scrollTab(vm, _roomIncomeContent(vm)),
            ],
          ),
        );
      },
    );
  }

  /* =============================
     SCROLLABLE WRAPPER (KEY FIX)
  ============================== */
  Widget _scrollTab(
      TransactionViewModel vm,
      Widget child,
      ) {
    return RefreshIndicator(
      onRefresh: () => _onRefresh(vm),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: child,
            ),
          );
        },
      ),
    );
  }

  /* =============================
     TAB CONTENTS
  ============================== */
  Widget _giftContent(TransactionViewModel vm) {
    if (vm.gifts.isEmpty) {
      return _empty("No gift transactions");
    }

    return Column(
      children: vm.gifts.map(_giftTile).toList(),
    );
  }

  Widget _rechargeContent(TransactionViewModel vm) {
    if (vm.recharges.isEmpty) {
      return _empty("No recharge history");
    }

    return Column(
      children: vm.recharges.map(_rechargeTile).toList(),
    );
  }

  Widget _roomIncomeContent(TransactionViewModel vm) {
    final s = vm.roomIncomeSummary;
    if (s == null) {
      return _empty("No room income data");
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Room Income Summary",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _row("Today", "${s.contributionTodayCoins} coins"),
          _row("Total", "${s.contributionTotalCoins} coins"),
          _row("Tier Paid", s.dailyRewardTierPaid.toString()),
          _row("Last Reset", s.lastResetAt?.toString() ?? "—"),
        ],
      ),
    );
  }

  /* =============================
     UI HELPERS
  ============================== */
  Widget _giftTile(GiftTransaction tx) {
    return ListTile(
      leading: const Icon(Icons.card_giftcard),
      title: Text(tx.giftName),
      subtitle:
      Text("From ${tx.senderId} → ${tx.receiverId}\n${tx.createdAt}"),
      trailing: Text("-${tx.coinsSpent} coins"),
    );
  }

  Widget _rechargeTile(TransactionModel tx) {
    return ListTile(
      leading: const Icon(Icons.account_balance_wallet),
      title: Text("${tx.coinsFinal} coins"),
      subtitle: Text("${tx.status.toUpperCase()} • ${tx.createdAt}"),
      trailing: Text("${tx.amount} ${tx.currency}"),
    );
  }

  Widget _empty(String text) {
    return SizedBox(
      height: 400,
      child: Center(child: Text(text)),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
