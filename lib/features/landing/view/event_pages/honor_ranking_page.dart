import 'package:flutter/material.dart';

class HonorRankingPage extends StatefulWidget {
  const HonorRankingPage({super.key});

  @override
  State<HonorRankingPage> createState() => _HonorRankingPageState();
}

class _HonorRankingPageState extends State<HonorRankingPage> {
  int _categoryIndex = 0;
  int _periodIndex = 1; // Weekly default

  final categories = ['Wealth', 'Charm', 'Room', 'Family'];
  final periods = ['Daily', 'Weekly', 'Monthly'];

  /* ================= THEMES ================= */

  final Map<String, List<Color>> categoryGradients = {
    'Wealth': [
      Color(0xFF5B0F1F),
      Color(0xFF3A1433),
      Color(0xFF1E0B24),
    ],
    'Charm': [
      Color(0xFF6A1B9A),
      Color(0xFF4A148C),
      Color(0xFF2A0845),
    ],
    'Room': [
      Color(0xFF0F4C5C),
      Color(0xFF083344),
      Color(0xFF041E2C),
    ],
    'Family': [
      Color(0xFF7C2D12),
      Color(0xFF4E1D09),
      Color(0xFF2A0E05),
    ],
  };

  final Map<String, Color> accentColors = {
    'Wealth': Colors.amber,
    'Charm': Colors.pinkAccent,
    'Room': Colors.cyanAccent,
    'Family': Colors.greenAccent,
  };

  List<Color> get _bg => categoryGradients[categories[_categoryIndex]]!;
  Color get _accent => accentColors[categories[_categoryIndex]]!;

  /// ✅ smart text color for active period
  Color get _activePeriodTextColor {
    final category = categories[_categoryIndex];

    if (category == 'Wealth') {
      return Colors.brown; // gold theme
    }

    // Charm / Room / Family
    return Colors.white;
  }

  /* ================= BUILD ================= */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _bg,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _header(context),
              const SizedBox(height: 12),
              _categoryTabs(),
              const SizedBox(height: 12),
              _periodTabs(),
              const SizedBox(height: 16),
              _topPodium(),
              const SizedBox(height: 14),
              Expanded(child: _rankingList()),
            ],
          ),
        ),
      ),
    );
  }

  /* ================= HEADER ================= */

  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          const Text(
            'Honor Ranking',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  /* ================= CATEGORY TABS ================= */

  Widget _categoryTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(categories.length, (i) {
        final active = _categoryIndex == i;

        return GestureDetector(
          onTap: () => setState(() => _categoryIndex = i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 6),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: active
                  ? Colors.white.withOpacity(0.12)
                  : Colors.black.withOpacity(0.25),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: active ? _accent.withOpacity(0.6) : Colors.transparent,
                width: 1,
              ),
            ),
            child: Text(
              categories[i],
              style: TextStyle(
                color: active ? Colors.white : Colors.white70,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
          ),
        );
      }),
    );
  }

  /* ================= PERIOD TABS ================= */

  Widget _periodTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(periods.length, (i) {
          final active = _periodIndex == i;

          return GestureDetector(
            onTap: () => setState(() => _periodIndex = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                gradient: active
                    ? LinearGradient(
                  colors: [
                    _accent.withOpacity(0.35),
                    _accent.withOpacity(0.2),
                  ],
                )
                    : null,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                periods[i],
                style: TextStyle(
                  color:
                  active ? _activePeriodTextColor : Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  /* ================= PODIUM ================= */

  Widget _topPodium() {
    return Column(
      children: [
        _top1(),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _TopMini(rank: 'TOP 2', accent: _accent,)),
            const SizedBox(width: 12),
            Expanded(child: _TopMini(rank: 'TOP 3', accent: _accent,)),
          ],
        ),
      ],
    );
  }

  Widget _top1() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [
            _accent.withOpacity(0.9),
            Colors.white.withOpacity(0.85),
          ],
        ),
      ),
      child: Column(
        children: const [
          Icon(Icons.emoji_events, size: 46, color: Colors.white),
          SizedBox(height: 8),
          CircleAvatar(
            radius: 38,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 42),
          ),
          SizedBox(height: 8),
          Text(
            'MIDNIGHT HAUZ AGENCY',
            style: TextStyle(
              color: Colors.brown,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /* ================= LIST ================= */

  Widget _rankingList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: 15,
      itemBuilder: (_, i) => _RankRow(
        rank: i + 4,
        accent: _accent,
      ),
    );
  }
}

/* ================= MINI PODIUM ================= */

class _TopMini extends StatelessWidget {
  final String rank;
  final Color accent;

  const _TopMini({
    required this.rank,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withOpacity(0.75),
            accent.withOpacity(0.35),
          ],
        ),
        border: Border.all(
          color: accent.withOpacity(0.6),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            rank,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 6),
          const CircleAvatar(
            radius: 26,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: Colors.black54),
          ),
          const SizedBox(height: 6),
          Text(
            'Behind ★ 1.2M',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}


/* ================= RANK ROW ================= */

class _RankRow extends StatelessWidget {
  final int rank;
  final Color accent;

  const _RankRow({required this.rank, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: [
            accent.withOpacity(0.28),
            Colors.black.withOpacity(0.45),
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '$rank',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          const CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white,
            child: Icon(Icons.person),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Username',
              style: TextStyle(color: Colors.white),
            ),
          ),
          const Text(
            'Behind ★ 120K',
            style: TextStyle(
              color: Colors.amber,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
