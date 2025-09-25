import 'package:flutter/material.dart';

class RechargeButton extends StatelessWidget {
  final VoidCallback onPressed;

  const RechargeButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 14),
      ),
      child: const Text("Recharge", style: TextStyle(fontSize: 16, color: Colors.white)),
    );
  }
}