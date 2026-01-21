import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/profile_picture_helper.dart';
import '../../landing_widgets/landing_widgets/event_widgets/event_header.dart';
import '../../viewmodel/event_ranking_viewmodel.dart';

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
    return DateTime(now.year, now.month, now.day)
        .add(Duration(days: (8 - now.weekday) % 7));
  }

  String _two(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EventRankingViewModel>();

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

            const _SectionTitle(title: 'This Week'),

            Expanded(
              child: vm.loading
                  ? const Center(child: CircularProgressIndicator())
                  : vm.weeklyStar.isEmpty
                  ? const Center(
                child: Text(
                  'No weekly stars yet',
                  style: TextStyle(color: Colors.white70),
                ),
              )
                  : ListView.builder(
                padding:
                const EdgeInsets.symmetric(horizontal: 16),
                itemCount: vm.weeklyStar.length,
                itemBuilder: (_, i) {
                  final r = vm.weeklyStar[i];
                  return _RankRow(
                    rank: r.rank,
                    userId: r.userId,
                    coins: r.value,
                  );
                },
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
  final String userId;
  final int coins;

  const _RankRow({
    required this.rank,
    required this.userId,
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
          UserAvatarHelper.circleAvatar(
            userIdentification: userId,
            displayName: userId,
            radius: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              userId,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          Text(
            '$coins',
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

/* ================= UI HELPERS ================= */

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

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
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
