import 'package:flutter/material.dart';

class VipBottomRenewBar extends StatelessWidget {
  final String coinsText;
  final String buttonText;
  final VoidCallback onRenew;

  const VipBottomRenewBar({
    super.key,
    required this.coinsText,
    required this.buttonText,
    required this.onRenew,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1007).withOpacity(0.92),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFFE7D6A5).withOpacity(0.14)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _CoinIcon(),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                coinsText,
                style: const TextStyle(
                  color: Color(0xFFE7D6A5),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            _RenewButton(text: buttonText, onTap: onRenew),
          ],
        ),
      ),
    );
  }
}

class _CoinIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26,
      width: 26,
      decoration: BoxDecoration(
        color: const Color(0xFFB67B2A).withOpacity(0.25),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFFE7D6A5).withOpacity(0.22)),
      ),
      child: const Icon(Icons.monetization_on_rounded, color: Color(0xFFFFD27A), size: 18),
    );
  }
}

class _RenewButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _RenewButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [
              const Color(0xFFFFE6A6),
              const Color(0xFFF0B44C).withOpacity(0.95),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.22),
              blurRadius: 12,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFF3B250A),
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}