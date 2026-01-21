import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/profile_picture_helper.dart';
import '../../landing_widgets/landing_widgets/event_widgets/event_header.dart';
import '../../viewmodel/event_ranking_viewmodel.dart';

class CPRankingPage extends StatefulWidget {
  const CPRankingPage({super.key});

  @override
  State<CPRankingPage> createState() => _CPRankingPageState();
}

class _CPRankingPageState extends State<CPRankingPage> {
  final int _step = 5;
  int _visibleCount = 7;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EventRankingViewModel>();
    final ranks = vm.couple;

    final visibleRanks = ranks.skip(3).take(_visibleCount).toList();

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
              child: vm.loading
                  ? const Center(child: CircularProgressIndicator())
                  : ranks.isEmpty
                  ? const Center(
                child: Text(
                  'No couple rankings yet',
                  style: TextStyle(color: Colors.white70),
                ),
              )
                  : ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  const SizedBox(height: 12),

                  _Top1Couple(ranks[0]),
                  const SizedBox(height: 16),

                  if (ranks.length > 2)
                    _Top23Row(ranks[1], ranks[2]),

                  const SizedBox(height: 20),

                  ...visibleRanks.map(
                        (e) => _RankRow(
                      rank: e.rank,
                      users: e.users,
                      score: e.value,
                    ),
                  ),

                  if (_visibleCount + 3 < ranks.length)
                    _MoreButton(
                      onTap: () => setState(() {
                        _visibleCount = (_visibleCount + _step)
                            .clamp(0, ranks.length);
                      }),
                    ),

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

/* ===================== PODIUM ===================== */

class _Top1Couple extends StatelessWidget {
  final dynamic data;
  const _Top1Couple(this.data);

  @override
  Widget build(BuildContext context) {
    return _PodiumCard(
      title: 'TOP 1',
      users: data.users,
      value: data.value,
      big: true,
    );
  }
}

class _Top23Row extends StatelessWidget {
  final dynamic a;
  final dynamic b;
  const _Top23Row(this.a, this.b);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _PodiumCard(title: 'TOP 2', users: a.users, value: a.value),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _PodiumCard(title: 'TOP 3', users: b.users, value: b.value),
        ),
      ],
    );
  }
}

class _PodiumCard extends StatelessWidget {
  final String title;
  final List<String> users;
  final int value;
  final bool big;

  const _PodiumCard({
    required this.title,
    required this.users,
    required this.value,
    this.big = false,
  });

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
          Text(title, style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              UserAvatarHelper.circleAvatar(
                userIdentification: users[0],
                displayName: users[0],
                radius: 28,
              ),
              const SizedBox(width: 8),
              const Icon(Icons.favorite, color: Colors.pinkAccent),
              const SizedBox(width: 8),
              UserAvatarHelper.circleAvatar(
                userIdentification: users[1],
                displayName: users[1],
                radius: 28,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '💛 ${value ~/ 1000}K',
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

/* ===================== RANK ROW ===================== */

class _RankRow extends StatelessWidget {
  final int rank;
  final List<String> users;
  final int score;

  const _RankRow({
    required this.rank,
    required this.users,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white.withOpacity(0.15),
      ),
      child: Row(
        children: [
          Text('$rank', style: const TextStyle(color: Colors.white)),
          const SizedBox(width: 12),
          UserAvatarHelper.circleAvatar(
            userIdentification: users[0],
            displayName: users[0],
            radius: 20,
          ),
          const Spacer(),
          const Icon(Icons.favorite, color: Colors.pinkAccent),
          const SizedBox(width: 6),
          Text(
            '${score ~/ 1000}K',
            style: const TextStyle(color: Colors.amber),
          ),
        ],
      ),
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
            ),
          ),
        ),
      ),
    );
  }
}
