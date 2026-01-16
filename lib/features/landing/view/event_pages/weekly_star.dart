import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../landing_widgets/landing_widgets/event_widgets/event_header.dart';

class WeeklyStar extends StatefulWidget {
  const WeeklyStar({super.key});

  @override
  State<WeeklyStar> createState() => _WeeklyStarState();
}

class _WeeklyStarState extends State<WeeklyStar> {
  late DateTime _resetTime;
  late Duration _remaining;
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _resetTime = _nextReset();
    _remaining = _resetTime.difference(DateTime.now());

    _ticker = Ticker((_) {
      setState(() {
        _remaining = _resetTime.difference(DateTime.now());
      });
    })..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  DateTime _nextReset() {
    final now = DateTime.now();
    final monday =
    DateTime(now.year, now.month, now.day).add(Duration(days: (8 - now.weekday) % 7));
    return monday;
  }

  String _two(int n) => n.toString().padLeft(2, '0');

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
              Color(0xFF77001A),
              Color(0xFF622525),
              Color(0xFF3A1C71),
            ],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(
              height: 140,
              child: EventHeader(
                title: '',
                background: 'assets/image/banner/weekly-star-banner.jpg',
              ),
            ),

            /// COUNTDOWN
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _TimeBox(label: 'Day', value: _remaining.inDays.toString()),
                  _TimeBox(label: 'Hour', value: _two(_remaining.inHours % 24)),
                  _TimeBox(label: 'Min', value: _two(_remaining.inMinutes % 60)),
                ],
              ),
            ),

            /// LAST WEEK TOP
            const _SectionTitle(title: 'Last Week TOP'),
            const SizedBox(height: 8),
            const _TopThree(),

            /// THIS WEEK
            const SizedBox(height: 16),
            const _SectionTitle(title: 'This Week'),
            const SizedBox(height: 8),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 8,
                itemBuilder: (_, i) => _RankRow(
                  rank: i + 4,
                  coins: '${(200000 - i * 9000) ~/ 1000}K',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ================= TIME BOX ================= */

class _TimeBox extends StatelessWidget {
  final String label;
  final String value;

  const _TimeBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.black38,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber),
            ),
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.amber,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}

/* ================= SECTION TITLE ================= */

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black38,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.amber),
        ),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.amber,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/* ================= TOP 3 ================= */

class _TopThree extends StatelessWidget {
  const _TopThree();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(child: _TopCard(rank: 'TOP 2', coins: '1.98M')),
        Expanded(child: _TopCard(rank: 'TOP 1', coins: '7.71M', big: true)),
        Expanded(child: _TopCard(rank: 'TOP 3', coins: '1.57M')),
      ],
    );
  }
}

class _TopCard extends StatelessWidget {
  final String rank;
  final String coins;
  final bool big;

  const _TopCard({
    required this.rank,
    required this.coins,
    this.big = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Container(
        height: big ? 150 : 120,
        decoration: BoxDecoration(
          color: Colors.black38,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.amber),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(rank, style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 6),
            const CircleAvatar(
              radius: 26,
              backgroundImage: AssetImage('assets/avatar.png'),
            ),
            const SizedBox(height: 6),
            Text(
              coins,
              style: const TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ================= RANK ROW ================= */

class _RankRow extends StatelessWidget {
  final int rank;
  final String coins;

  const _RankRow({
    required this.rank,
    required this.coins,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.amber),
      ),
      child: Row(
        children: [
          Text('$rank', style: const TextStyle(color: Colors.white)),
          const SizedBox(width: 12),
          const CircleAvatar(
            backgroundImage: AssetImage('assets/avatar.png'),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'User Name',
              style: TextStyle(color: Colors.white),
            ),
          ),
          Text(
            coins,
            style: const TextStyle(
              color: Colors.amber,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
