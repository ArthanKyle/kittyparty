// lib/features/landing/landing_widgets/profile_widgets/daily_widgets/daily_task_list.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/utils/user_provider.dart';
import '../../../viewmodel/dailyTask_viewmodel.dart';
import 'task_card.dart';

class DailyTaskList extends StatelessWidget {
  final DailyTaskViewModel viewModel;

  const DailyTaskList({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    if (viewModel.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // ✅ Get userIdentification once
    final uid = context.read<UserProvider>().currentUser?.userIdentification ?? "";

    // ✅ Listen for claiming state so buttons update
    final isClaiming = context.watch<DailyTaskViewModel>().isClaiming;

    return Column(
      children: viewModel.dailyTasks.map((t) {
        final target = (t.target <= 0) ? 1 : t.target;
        final ratio = (t.progress / target).clamp(0.0, 1.0);

        // ✅ Receive enabled only if completed and not yet rewarded
        final canReceive = (t.completed == true) && (t.rewarded == false);

        // ✅ If you want sign_in to be handled ONLY by the header button:
        final showReceive = t.key != 'sign_in';

        return TaskCard(
          title: t.title,
          subtitle: t.subtitle,
          reward: t.reward,
          rewardIcon: Image.asset(
            'assets/icons/KPcoin.png',
            width: 18,
            height: 18,
            fit: BoxFit.contain,
          ),
          completed: t.completed,
          rewarded: t.rewarded,
          progress: ratio,

          // ✅ Receive button behavior
          showReceive: showReceive,
          receiveEnabled: showReceive && canReceive && !isClaiming && uid.isNotEmpty,
          onReceive: showReceive
              ? () async {
            final vm = context.read<DailyTaskViewModel>();
            await vm.claim(uid, t.key);
          }
              : null,
        );
      }).toList(),
    );
  }
}
