import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';


class ProfileGradientBackground extends StatelessWidget {
  final Widget child;
  final double fadeHeight; // where the fade ends

  const ProfileGradientBackground({
    super.key,
    required this.child,
    this.fadeHeight = 20, // default fade position
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gradient + fade
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primaryDark,
                  Colors.white,
                ],
                stops: [0.0, 0.6, 2.0], // fade point
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}