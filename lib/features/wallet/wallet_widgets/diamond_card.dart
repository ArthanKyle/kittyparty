import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

class DiamondCard extends StatelessWidget {
  final int balance;
  final VoidCallback onConvert;

  const DiamondCard({
    super.key,
    required this.balance,
    required this.onConvert,
  });

  @override
  Widget build(BuildContext context) {
    const double imageSize = 170.0;
    const double overlapAmount = 35.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12 + overlapAmount / 2),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.diamondGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "My Diamonds",
                      style: TextStyle(fontSize: 14, color: AppColors.gray),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "$balance",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: onConvert,
                      child: const Text(
                        "Convert >",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: imageSize - overlapAmount),
              ],
            ),
          ),
          Positioned(
            top: -overlapAmount,
            right: -overlapAmount / 2,
            child: Image.asset(
              "assets/icons/jewel.PNG",
              height: imageSize,
              width: imageSize,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
