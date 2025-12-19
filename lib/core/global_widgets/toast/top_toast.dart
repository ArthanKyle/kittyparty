import 'package:flutter/material.dart';

class TopToast {
  static void show(
      BuildContext context, {
        required String message,
        Duration duration = const Duration(seconds: 2),
      }) {
    final overlay = Overlay.of(context, rootOverlay: true);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => TopToastWidget(message: message),
    );

    overlay.insert(entry);

    Future.delayed(duration, () {
      entry.remove();
    });
  }
}

class TopToastWidget extends StatelessWidget {
  final String message;

  const TopToastWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      left: 16,
      right: 16,
      child: IgnorePointer(
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.35),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white24),
            ),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
