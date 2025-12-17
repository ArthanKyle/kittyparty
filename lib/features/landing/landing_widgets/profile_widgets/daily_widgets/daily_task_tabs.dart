import 'package:flutter/material.dart';

class TaskTabs extends StatelessWidget {
  const TaskTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          _TabItem(text: 'Daily Tasks', active: true),
          _TabItem(text: 'Weekly Tasks', active: false),
          _TabItem(text: 'Agent Tasks', active: false),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String text;
  final bool active;

  const _TabItem({
    required this.text,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          text,
          style: TextStyle(
            color: active ? Colors.orange : Colors.grey,
            fontWeight:
            active ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        if (active)
          Container(
            margin: const EdgeInsets.only(top: 4),
            height: 3,
            width: 60,
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
      ],
    );
  }
}
