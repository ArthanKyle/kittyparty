import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ModeCard extends StatelessWidget {
  final String title;
  final double height;
  final List<Color> gradient;
  final IconData icon;


  const ModeCard({
    required this.title,
    required this.height,
    required this.gradient,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: 14,
            top: 14,
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight:
                  title == title.toUpperCase() ? FontWeight.w800 : FontWeight.w700,
                  fontSize: title == title.toUpperCase() ? 22 : 18,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}