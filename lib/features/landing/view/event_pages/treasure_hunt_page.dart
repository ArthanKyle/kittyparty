import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../landing_widgets/landing_widgets/event_widgets/event_header.dart';

class TreasureHuntPage extends StatelessWidget {
  const TreasureHuntPage({super.key});

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
              Color(0xFF8B2C1E),
              Color(0xFF5B1C10),
              Color(0xFF2E0B06),
            ],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            /// ✅ EVENT HEADER (SAME ARCHITECTURE AS WEALTH)
            SizedBox(
              height: 160,
              child: Stack(
                children: [
                  const EventHeader(
                    title: '',
                    background: 'assets/image/banner/treasure-gold-coins-banner.jpg',
                  ),

                  /// 🔙 BACK ARROW (BEST POSITION)
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
                ],
              ),
            ),



            const SizedBox(height: 16),

            const _TreasureChest(),
            const SizedBox(height: 20),

            const _BetButtons(),
            const SizedBox(height: 16),

            const _DescriptionBox(),
            const SizedBox(height: 20),

            _TabButtons(onRankingTap: () {  },), // <-- your ranking page

            const SizedBox(height: 16),

            const _WeeklyInfo(),
            const SizedBox(height: 20),

            const _AdventureTask(
              title: 'First recharge per week',
              progress: '0/1',
              points: '+100',
            ),
            const _AdventureTask(
              title: 'Recharge 50,000 within 1 day',
              progress: '0/50000',
              points: '+70',
            ),
            const _AdventureTask(
              title: 'Recharge 50,000 for 3 consecutive days',
              progress: '0/3',
              points: '+150',
            ),
            const _AdventureTask(
              title: 'Recharge 50,000 for 7 consecutive days',
              progress: '0/7',
              points: '+230',
            ),
            const _AdventureTask(
              title: 'Recharge 400,000 within 7 days',
              progress: '0/400000',
              points: '+300',
            ),
            const _AdventureTask(
              title: 'Recharge 1,000,000 within 7 days',
              progress: '0/1000000',
              points: '+350',
            ),

            const SizedBox(height: 24),

            const Center(
              child: Text(
                'Event has nothing to do with Google',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

/* ================= TREASURE CHEST ================= */

class _TreasureChest extends StatelessWidget {
  const _TreasureChest();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          'assets/icons/treasure.png',
          width: 300,
          height: 300,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 8),
        const Text(
          'Treasure Hunt Challenge',
          style: TextStyle(
            color: Colors.amber,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Earn points by participating,\nTreasures are waiting for you!',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70),
        ),
      ],
    );
  }
}



/* ================= BET BUTTONS ================= */

class _BetButtons extends StatelessWidget {
  const _BetButtons();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: const [
          Expanded(
            child: _BetButton(
              label: '1 Bet',
              sub: 'Need 100 points',
              color: Colors.green,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _BetButton(
              label: '10 Bet',
              sub: 'Need 1000 points',
              color: Colors.cyan,
            ),
          ),
        ],
      ),
    );
  }
}

class _BetButton extends StatelessWidget {
  final String label;
  final String sub;
  final Color color;

  const _BetButton({
    required this.label,
    required this.sub,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sub,
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

/* ================= DESCRIPTION ================= */

class _DescriptionBox extends StatelessWidget {
  const _DescriptionBox();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.amber),
        ),
        child: const Text(
          'Join this adventure full of unknowns and\naccumulate adventure points for each task you complete!',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

/* ================= TAB BUTTONS ================= */

class _TabButtons extends StatelessWidget {
  final VoidCallback onRankingTap;

  const _TabButtons({
    required this.onRankingTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Expanded(
            child: _TabButton(
              title: 'Adventure Task',
              active: true,
            ),
          ),
          const SizedBox(width: 12),

          /// ✅ FIXED: Proper tappable button
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: onRankingTap,
                child: const _TabButton(
                  title: 'Adventure Ranking',
                  active: false,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _TabButton extends StatelessWidget {
  final String title;
  final bool active;

  const _TabButton({
    required this.title,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: active ? Colors.redAccent : Colors.red.withOpacity(0.3),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/* ================= WEEKLY INFO ================= */

class _WeeklyInfo extends StatefulWidget {
  const _WeeklyInfo();

  @override
  State<_WeeklyInfo> createState() => _WeeklyInfoState();
}

class _WeeklyInfoState extends State<_WeeklyInfo> {
  late DateTime _resetTime;
  late Duration _remaining;
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();

    _resetTime = _getNextWeeklyReset();
    _remaining = _resetTime.difference(DateTime.now());

    _ticker = Ticker((_) {
      final diff = _resetTime.difference(DateTime.now());
      if (diff.isNegative) {
        _resetTime = _getNextWeeklyReset();
        _remaining = _resetTime.difference(DateTime.now());
      } else {
        setState(() {
          _remaining = diff;
        });
      }
    })..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  DateTime _getNextWeeklyReset() {
    final now = DateTime.now();

    final nextMonday =
    DateTime(now.year, now.month, now.day)
        .add(Duration(days: (8 - now.weekday) % 7));

    return DateTime(
      nextMonday.year,
      nextMonday.month,
      nextMonday.day,
    );
  }

  String _format(Duration d) {
    final days = d.inDays;
    final hours = d.inHours % 24;
    final minutes = d.inMinutes % 60;
    final seconds = d.inSeconds % 60;

    String two(int n) => n.toString().padLeft(2, '0');

    return '$days Days ${two(hours)}:${two(minutes)}:${two(seconds)}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.amber),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reset time: ${_format(_remaining)}',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 6),
            const Text(
              'Points earned this week: 0',
              style: TextStyle(color: Colors.white70),
            ),
            const Text(
              'Remaining Points this week: 0',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}


/* ================= TASK ITEM ================= */

class _AdventureTask extends StatelessWidget {
  final String title;
  final String progress;
  final String points;

  const _AdventureTask({
    required this.title,
    required this.progress,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.25),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.amber),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    progress,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            Text(
              points,
              style: const TextStyle(
                color: Colors.amber,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
