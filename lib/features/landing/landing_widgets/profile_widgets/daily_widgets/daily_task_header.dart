import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodel/dailyTask_viewmodel.dart';

class DailyTaskHeader extends StatelessWidget {
  final String? token;

  const DailyTaskHeader({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFE4A0), Color(0xFFFFF0D1)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Task Center',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.brown,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: token == null
                ? null
                : () {
              context
                  .read<DailyTaskViewModel>()
                  .signIn(token!);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(
                horizontal: 40,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              'Sign in now',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
