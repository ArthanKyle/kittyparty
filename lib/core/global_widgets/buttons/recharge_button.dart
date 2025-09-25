import 'package:flutter/material.dart';

class RechargeButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool enabled;

  const RechargeButton({
    Key? key,
    required this.onPressed,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30), // fully rounded
          ),
          backgroundColor: Colors.blueAccent,
          disabledBackgroundColor: Colors.grey.shade300,
        ),
        child: const Text(
          "Recharge",
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }
}
