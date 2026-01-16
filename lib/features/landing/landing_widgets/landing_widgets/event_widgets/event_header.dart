import 'package:flutter/material.dart';

class EventHeader extends StatelessWidget {
  final String title;
  final String background;
  final bool showBack; // optional toggle

  const EventHeader({
    super.key,
    required this.title,
    required this.background,
    this.showBack = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        /// BACKGROUND IMAGE
        Image.asset(
          background,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        ),

        /// BACK BUTTON (TOP-LEFT)
        if (showBack)
          Positioned(
            left: 8,
            top: 8,
            child: SafeArea(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),

        /// TITLE (BOTTOM CENTER)
        if (title.isNotEmpty)
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
