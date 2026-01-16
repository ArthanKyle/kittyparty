import 'package:flutter/material.dart';
import '../../landing_widgets/landing_widgets/event_widgets/event_header.dart';

class CPRankingPage extends StatefulWidget {
  const CPRankingPage({super.key});

  @override
  State<CPRankingPage> createState() => _CPRankingPageState();
}

class _CPRankingPageState extends State<CPRankingPage> {
  final int _step = 5;
  int _visibleCount = 7;

  late final List<_RankData> _allRanks = List.generate(
    30,
        (i) => _RankData(
      rank: i + 4,
      score: '${(1200000 - i * 25000) ~/ 1000}K',
    ),
  );

  void _loadMore() {
    setState(() {
      _visibleCount =
          (_visibleCount + _step).clamp(0, _allRanks.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    final visibleRanks = _allRanks.take(_visibleCount).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFD95C9A),
              Color(0xFF7E3167),
              Color(0xFF452064),
            ],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(
              height: 120,
              child: EventHeader(
                title: '',
                background: 'assets/image/banner/couple-event-banner.jpg',
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  const SizedBox(height: 12),

                  const _Top1Couple(),
                  const SizedBox(height: 16),
                  const _Top23Row(),
                  const SizedBox(height: 20),

                  ...visibleRanks.map(
                        (e) => _RankRow(rank: e.rank, score: e.score),
                  ),

                  const SizedBox(height: 16),

                  if (_visibleCount < _allRanks.length)
                    _MoreButton(onTap: _loadMore),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ===================== DATA ===================== */

class _RankData {
  final int rank;
  final String score;

  _RankData({required this.rank, required this.score});
}

/* ===================== TOP 1 ===================== */

class _Top1Couple extends StatelessWidget {
  const _Top1Couple();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFFB26DFF), Color(0xFFFF9ACD)],
        ),
      ),
      child: Column(
        children: [
          const Text(
            'TOP 1',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              _Avatar(size: 64),
              SizedBox(width: 12),
              Icon(Icons.favorite, color: Colors.pinkAccent, size: 30),
              SizedBox(width: 12),
              _Avatar(size: 64),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            '💛 5.69M',
            style: TextStyle(
              color: Colors.amber,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/* ===================== TOP 2 & 3 ===================== */

class _Top23Row extends StatelessWidget {
  const _Top23Row();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(child: _TopMini(rank: 'TOP 2', score: '2.99M')),
        SizedBox(width: 12),
        Expanded(child: _TopMini(rank: 'TOP 3', score: '2.95M')),
      ],
    );
  }
}

class _TopMini extends StatelessWidget {
  final String rank;
  final String score;

  const _TopMini({required this.rank, required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF9F7BFF), Color(0xFFFF9ACD)],
        ),
      ),
      child: Column(
        children: [
          Text(
            rank,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const _Avatar(size: 50),
          const SizedBox(height: 6),
          Text(
            '💛 $score',
            style: const TextStyle(color: Colors.amber),
          ),
        ],
      ),
    );
  }
}

/* ===================== RANK ROW ===================== */

class _RankRow extends StatelessWidget {
  final int rank;
  final String score;

  const _RankRow({required this.rank, required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white.withOpacity(0.15),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          Text(
            '$rank',
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(width: 12),
          const _Avatar(size: 40),
          const Spacer(),
          const Icon(Icons.favorite, color: Colors.pinkAccent),
          const SizedBox(width: 6),
          Text(
            score,
            style: const TextStyle(color: Colors.amber),
          ),
        ],
      ),
    );
  }
}

/* ===================== AVATAR ===================== */

class _Avatar extends StatelessWidget {
  final double size;

  const _Avatar({required this.size});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundImage: const AssetImage('assets/avatar.png'),
    );
  }
}

/* ===================== MORE BUTTON ===================== */

class _MoreButton extends StatelessWidget {
  final VoidCallback onTap;

  const _MoreButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.amber,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Text(
            'More',
            style: TextStyle(
              color: Colors.brown,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
