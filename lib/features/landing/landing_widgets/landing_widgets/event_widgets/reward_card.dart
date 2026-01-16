import 'package:flutter/material.dart';

import '../../../model/reward_item.dart';


class RewardCard extends StatelessWidget {
  final RewardItem item;

  const RewardCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(item.image, height: 90),
        const SizedBox(height: 6),
        Text(
          item.title,
          style: const TextStyle(color: Colors.white),
        ),
        if (item.duration.isNotEmpty)
          Text(
            item.duration,
            style: const TextStyle(color: Colors.orange, fontSize: 12),
          ),
        if (item.isPermanent)
          const Text(
            'Forever',
            style: TextStyle(color: Colors.green, fontSize: 12),
          ),
      ],
    );
  }
}
