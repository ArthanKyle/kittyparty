import 'package:flutter/material.dart';

enum UserGender { male, female }

class GenderBadge extends StatelessWidget {
  final UserGender gender;
  final double size;

  const GenderBadge({
    super.key,
    required this.gender,
    this.size = 22,
  });

  @override
  Widget build(BuildContext context) {
    final style = _GenderBadgeStyle.fromGender(gender);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: style.bg,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(
        style.icon,
        size: size * 0.68,
        color: style.iconColor,
      ),
    );
  }
}

class _GenderBadgeStyle {
  final Color bg;
  final IconData icon;
  final Color iconColor;

  const _GenderBadgeStyle({
    required this.bg,
    required this.icon,
    required this.iconColor,
  });

  factory _GenderBadgeStyle.fromGender(UserGender gender) {
    switch (gender) {
      case UserGender.male:
        return const _GenderBadgeStyle(
          bg: Color(0xFF4A90E2),
          icon: Icons.male,
          iconColor: Colors.white,
        );
      case UserGender.female:
        return const _GenderBadgeStyle(
          bg: Color(0xFFFF5CA8),
          icon: Icons.female,
          iconColor: Colors.white,
        );
    }
  }
}
