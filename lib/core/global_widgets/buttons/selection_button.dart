import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class SelectionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final bool isDisabled;

  const SelectionButton({
    super.key,
    this.onPressed,
    required this.text,
    required this.isDisabled
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDisabled ? Colors.grey : AppColors.primaryDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(35),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
