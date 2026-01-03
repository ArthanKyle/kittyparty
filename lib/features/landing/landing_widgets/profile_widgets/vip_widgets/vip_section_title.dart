import 'package:flutter/material.dart';

class VipSectionTitle extends StatelessWidget {
  final String title;
  final String? trailingText;

  const VipSectionTitle({
    super.key,
    required this.title,
    this.trailingText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _OrnamentLine(leftToRight: true)),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFFE7D6A5),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (trailingText != null) ...[
          const SizedBox(width: 8),
          Text(
            trailingText!,
            style: TextStyle(
              color: const Color(0xFFE7D6A5).withOpacity(0.9),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
        const SizedBox(width: 10),
        Expanded(child: _OrnamentLine(leftToRight: false)),
      ],
    );
  }
}

class _OrnamentLine extends StatelessWidget {
  final bool leftToRight;
  const _OrnamentLine({required this.leftToRight});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 14,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: leftToRight ? Alignment.centerLeft : Alignment.centerRight,
          end: leftToRight ? Alignment.centerRight : Alignment.centerLeft,
          colors: [
            Colors.transparent,
            const Color(0xFFE7D6A5).withOpacity(0.55),
            Colors.transparent,
          ],
        ),
      ),
      child: Center(
        child: Container(
          height: 1.2,
          color: const Color(0xFFE7D6A5).withOpacity(0.55),
        ),
      ),
    );
  }
}
