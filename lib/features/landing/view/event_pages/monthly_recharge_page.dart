import 'package:flutter/material.dart';
import '../../landing_widgets/landing_widgets/event_widgets/event_header.dart';
import '../../landing_widgets/landing_widgets/event_widgets/recharge_tier_card.dart';
import '../../model/recharge_tier.dart';
import '../../model/reward_item.dart';


class MonthlyRechargePage extends StatelessWidget {
  const MonthlyRechargePage({super.key});

  @override
  Widget build(BuildContext context) {
    final tiers = [
      RechargeTier(
        amount: 10,
        rewards: [
          RewardItem(title: 'Vehicle', image: 'assets/events/vehicle.png', duration: '7 days'),
          RewardItem(title: 'VIP1', image: 'assets/events/vip1.png', duration: '7 days'),
        ],
      ),
      RechargeTier(
        amount: 100,
        rewards: [
          RewardItem(title: 'Vehicle', image: 'assets/events/vehicle2.png', duration: '15 days'),
          RewardItem(title: 'VIP2', image: 'assets/events/vip2.png', duration: '7 days'),
        ],
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF3B1C0A),
      body: ListView(
        children: [
          const SizedBox(
            height: 120,
            child: EventHeader(
              title: '',
              background: 'assets/image/banner/monthly-recharge-banner.jpg',
            ),
          ),
          ...tiers.map((e) => RechargeTierCard(tier: e)),
        ],
      ),
    );
  }
}
