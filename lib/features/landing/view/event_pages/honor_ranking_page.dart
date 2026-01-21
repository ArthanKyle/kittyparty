import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/profile_picture_helper.dart';
import '../../viewmodel/event_ranking_viewmodel.dart';


class HonorRankingPage extends StatefulWidget {
  const HonorRankingPage({super.key});

  @override
  State<HonorRankingPage> createState() => _HonorRankingPageState();
}

class _HonorRankingPageState extends State<HonorRankingPage> {
  int _categoryIndex = 0;
  int _periodIndex = 1; // Weekly default

  // ⚠️ Only Wealth & Charm are active
  final categories = ['Wealth', 'Charm', 'Room', 'Family'];
  final periods = ['Daily', 'Weekly', 'Monthly'];

  final Map<String, List<Color>> categoryGradients = {
    'Wealth': [Color(0xFF5B0F1F), Color(0xFF3A1433), Color(0xFF1E0B24)],
    'Charm': [Color(0xFF6A1B9A), Color(0xFF4A148C), Color(0xFF2A0845)],
    'Room': [Color(0xFF0F4C5C), Color(0xFF083344), Color(0xFF041E2C)],
    'Family': [Color(0xFF7C2D12), Color(0xFF4E1D09), Color(0xFF2A0E05)],
  };

  final Map<String, Color> accentColors = {
    'Wealth': Colors.amber,
    'Charm': Colors.pinkAccent,
    'Room': Colors.cyanAccent,
    'Family': Colors.greenAccent,
  };

  List<Color> get _bg => categoryGradients[categories[_categoryIndex]]!;
  Color get _accent => accentColors[categories[_categoryIndex]]!;

  bool get _categorySupported =>
      _categoryIndex == 0 || _categoryIndex == 1;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EventRankingViewModel>();

    final data = !_categorySupported
        ? const []
        : _categoryIndex == 0
        ? vm.honorWealth
        : vm.honorCharm;

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

              if (!_categorySupported)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Coming Soon',
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              else if (vm.loading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (data.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Text(
                        'No ranking data',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: data.length,
                      itemBuilder: (_, i) => _RankRow(
                        rank: data[i].rank,
                        userId: data[i].userId,
                        value: data[i].value,
                        accent: _accent,
                      ),
                    ),
                  ),
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
              ),
            ),
            child: Text(
              categories[i],
              style: const TextStyle(color: Colors.white),
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
                  color: active ? Colors.white : Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/* ================= RANK ROW ================= */

class _RankRow extends StatelessWidget {
  final int rank;
  final String userId;
  final int value;
  final Color accent;

  const _RankRow({
    required this.rank,
    required this.userId,
    required this.value,
    required this.accent,
  });

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
          UserAvatarHelper.circleAvatar(
            userIdentification: userId,
            displayName: userId,
            radius: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              userId,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          Text(
            '$value',
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
