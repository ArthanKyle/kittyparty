import 'package:flutter/material.dart';

class TaskCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final int reward;
  final Widget rewardIcon;
  final bool completed;
  final double progress;

  const TaskCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.reward,
    required this.rewardIcon,
    required this.completed,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final color = completed ? Colors.grey : Colors.orange;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.15),
            radius: 24,
            child: Icon(
              Icons.task_alt,
              color: color,
            ),
          ),
          const SizedBox(width: 12),

          // TEXT + PROGRESS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: const TextStyle(color: Colors.grey),
                  ),
                if (!completed && progress > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      color: Colors.orange,
                      backgroundColor: Colors.grey.shade200,
                    ),
                  ),
              ],
            ),
          ),

          // REWARD
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              rewardIcon,
              const SizedBox(width: 4),
              Text(
                "+$reward",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: completed ? Colors.grey : Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
