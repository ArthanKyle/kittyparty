import 'package:flutter/material.dart';
import '../../landing_widgets/landing_widgets/event_widgets/event_header.dart';

class WealthRewardPage extends StatelessWidget {
  const WealthRewardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF3B1C0A),
              Color(0xFF5C2A10),
              Color(0xFF8A3E1B),
            ],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: const [
            SizedBox(
              height: 120,
              child: EventHeader(
                title: '',
                background: 'assets/image/banner/wealth-level-reward-banner.jpg',
              ),
            ),

            SizedBox(height: 16),

            _WealthSection(level: 50),
            _WealthSection(level: 60),
            _WealthSection(level: 70),
            _WealthSection(level: 80),

            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

/* ================= WEALTH SECTION ================= */

class _WealthSection extends StatelessWidget {
  final int level;

  const _WealthSection({required this.level});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.amber),
          gradient: LinearGradient(
            colors: [
              Colors.brown.shade900,
              Colors.brown.shade700,
            ],
          ),
        ),
        child: Column(
          children: [
            Text(
              'Available when reaching Wealth Lv.$level',
              style: const TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            /// BANNER PLACEHOLDER
            Container(
              height: 70,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.black26,
                border: Border.all(color: Colors.amber),
              ),
              alignment: Alignment.center,
              child: Text(
                'Banner Lv.$level  •  +14 Days',
                style: const TextStyle(color: Colors.white),
              ),
            ),

            const SizedBox(height: 16),

            /// REWARDS GRID
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.9,
              children: [
                _RewardItem(title: 'Vehicle', level: level),
                _RewardItem(title: 'Medal', level: level),
                _RewardItem(title: 'Headwear', level: level),
                _RewardItem(title: 'Bubble', level: level),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/* ================= REWARD ITEM ================= */

class _RewardItem extends StatelessWidget {
  final String title;
  final int level;

  const _RewardItem({
    required this.title,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.amber),
        color: Colors.black26,
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.black38,
              ),
              alignment: Alignment.center,
              child: Text(
                'LV.$level',
                style: const TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 4),
          const Text(
            'Forever',
            style: TextStyle(
              color: Colors.amber,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
