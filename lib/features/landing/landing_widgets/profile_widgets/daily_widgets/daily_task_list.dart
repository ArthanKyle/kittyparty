import 'package:flutter/material.dart';
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
        child: CircularProgressIndicator(),
      );
    }

    Widget rewardIcon(String taskKey) {
      switch (taskKey) {
        case "sign_in":
        case "room_income":
        case "recharge_7000":
          return Image.asset(
            "assets/icons/KPcoin.png",
            width: 16,
            height: 16,
          );

        default:
          return const SizedBox();
      }
    }


    return Column(
      children: viewModel.dailyTasks.map((task) {
        return TaskCard(
          title: task.title,
          subtitle: task.subtitle,
          reward: task.reward,
          rewardIcon: rewardIcon(task.key), // 👈 HERE
          completed: task.completed,
          progress: task.target == 0
              ? 0
              : task.progress / task.target,
        );
      }).toList(),
    );
  }
}
