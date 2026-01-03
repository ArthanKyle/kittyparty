import 'package:flutter/material.dart';
import 'vip_medal_assets.dart';

class VipHeaderCard extends StatelessWidget {
  final int vipLevel;
  final bool obtainedVip;
  final String subtitle;

  const VipHeaderCard({
    super.key,
    required this.vipLevel,
    required this.obtainedVip,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: const Color(0xFFDDF0B3),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'VIP$vipLevel',
                  style: TextStyle(
                    color: const Color(0xFF2E3D12).withOpacity(0.75),
                    fontSize: 44,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF2B2B2B),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          _MedalDisplay(vipLevel: vipLevel),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}

class _MedalDisplay extends StatelessWidget {
  final int vipLevel;
  const _MedalDisplay({required this.vipLevel});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      height: 130,
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // pedestal-ish shape
          Positioned(
            bottom: 12,
            child: Container(
              width: 126,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.28),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Image.asset(
            VipMedalAssets.medalPngByLevel(vipLevel),
            width: 120,
            height: 120,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.emoji_events_rounded,
              size: 64,
              color: Color(0xFF6C7B2C),
            ),
          ),
        ],
      ),
    );
  }
}
