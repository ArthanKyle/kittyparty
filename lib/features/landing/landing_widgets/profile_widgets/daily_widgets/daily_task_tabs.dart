import 'package:flutter/material.dart';

class TaskTabs extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int> onChanged;

  const TaskTabs({
    super.key,
    required this.activeIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _TabItem(
            text: 'Daily Tasks',
            active: activeIndex == 0,
            onTap: () => onChanged(0),
          ),
          _TabItem(
            text: 'Weekly Tasks',
            active: activeIndex == 1,
            onTap: () => onChanged(1),
          ),
          _TabItem(
            text: 'Agent Tasks',
            active: activeIndex == 2,
            onTap: () => onChanged(2),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String text;
  final bool active;
  final VoidCallback onTap;

  const _TabItem({
    required this.text,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Text(
            text,
            style: TextStyle(
              color: active ? Colors.orange : Colors.grey,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
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
      ),
    );
  }
}
