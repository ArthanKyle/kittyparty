import 'package:flutter/material.dart';
import '../../constants/colors.dart';



class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ...AppColors.mainGradient,
            Colors.white, // fade into white at the end
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.7, 1.0], // smooth fade near the bottom
        ),
      ),
      child: child,
    );
  }
}