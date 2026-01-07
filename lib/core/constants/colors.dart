import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFD946EF); // Bright Magenta Purple
  static const Color primaryLight = Color(0xFFA78BFA); // Soft Lavender Purple
  static const Color primaryDark = Color(0xFF6A0DAD); // Royal Purple
  static const Color accentPink = Color(0xFFF15BB5); // Pink Candy
  static const Color accentYellow = Color(0xFFFEE440); // Sun Pop
  static const Color accentWhite = Color(0xFFF5F5F5); // Soft White
  static const Color gray = Color(0xFF9E9E9E); // Medium Gray
  static const Color background = Color(0xFFF9F7FF); // Lilac Mist
  static const Color textDark = Color(0xFF2B2B2B); // Midnight Ink
  static const Color textLight = Colors.white; // Pure White
  static const Color errorColor = Color(0xFFE63946); // Coral Red
  static const Color solidBlack = Colors.black; // Solid Black
  static const Color accentBlack = Color(0xFF171717);
  static const Color gold = Color(0xFFFFB300);

  /// Main gradient (Kitty Party theme)
  static const List<Color> mainGradient = [
    primary, // #D946EF
    primaryLight, // #A78BFA
  ];

  /// Optional other gradients
  static const List<Color> buttonGradient = [primaryDark, primary];

  static const List<Color> softGradient = [primaryLight, accentPink];
  static const List<Color> goldShineGradient = [
    Color(0xFFFFD700),
    Color(0xFFFFB300),
    Color(0xFFFFF8E1),
  ];

  static const List<Color> diamondGradient = [
    Color(0xFF00C9FF), // Vibrant Aqua Blue
    Color(0xFF00E0FF), // Electric Cyan (adds shine)
    Color(0xFFE0F7FA), // Crystal White-Blue highlight
  ];

  static const List<Color> grayGradient = [
    Color(0xFFB0B0B0),
    Color(0xFFE0E0E0),
  ];
}