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

    return Column(
      children: viewModel.dailyTasks.map((task) {
        return TaskCard(
          title: task.title,
          subtitle: task.subtitle,
          reward:
          "+${task.reward} ${task.rewardUnit}",
          completed: task.completed,
          progress: task.target == 0
              ? 0
              : task.progress / task.target,
        );
      }).toList(),
    );
  }
}
