import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/profile_picture_helper.dart';
import '../../../../core/utils/user_provider.dart';
import '../../viewmodel/event_ranking_viewmodel.dart';
import '../../model/ranking_entry.dart';

class HonorRankingPage extends StatefulWidget {
  const HonorRankingPage({super.key});

  @override
  State<HonorRankingPage> createState() => _HonorRankingPageState();
}

class _HonorRankingPageState extends State<HonorRankingPage> {
  int _categoryIndex = 0;
  int _periodIndex = 1;

  final categories = ['Wealth', 'Charm', 'Room', 'Family'];
  final periods = ['Daily', 'Weekly', 'Monthly'];

  String _displayName(RankingEntry entry) {
    return (entry.username?.trim().isNotEmpty == true)
        ? entry.username!
        : entry.userId;
  }

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

  bool get _categorySupported => _categoryIndex <= 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<UserProvider>().token!;
      final vm = context.read<EventRankingViewModel>();
      vm.loadHonorWealth(token);
      vm.loadHonorCharm(token);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EventRankingViewModel>();

    final List<RankingEntry> data = !_categorySupported
        ? []
        : (_categoryIndex == 0 ? vm.honorWealth : vm.honorCharm);

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
                  child: Text('Coming Soon',
                      style: TextStyle(color: Colors.white70)),
                )
              else if (vm.loading)
                const Expanded(
                    child: Center(child: CircularProgressIndicator()))
              else if (data.isEmpty)
                  const Expanded(
                      child: Center(
                          child: Text('No ranking data',
                              style: TextStyle(color: Colors.white70))))
                else ...[
                    _TopPodium(data: data, accent: _accent),
                    const SizedBox(height: 14),
                    Expanded(child: _RankingList(data: data, accent: _accent)),
                  ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context)),
          const Spacer(),
          const Text('Honor Ranking',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          const Spacer(),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

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
            padding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: active
                  ? Colors.white.withOpacity(0.12)
                  : Colors.black.withOpacity(0.25),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                  color:
                  active ? _accent.withOpacity(0.6) : Colors.transparent),
            ),
            child: Text(categories[i],
                style: TextStyle(
                    color: active ? Colors.white : Colors.white70,
                    fontWeight:
                    active ? FontWeight.bold : FontWeight.normal)),
          ),
        );
      }),
    );
  }

  Widget _periodTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: Colors.black45,
          borderRadius: BorderRadius.circular(22)),
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
                    ? LinearGradient(colors: [
                  _accent.withOpacity(0.35),
                  _accent.withOpacity(0.2)
                ])
                    : null,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(periods[i],
                  style: TextStyle(
                      color: active ? Colors.white : Colors.white70,
                      fontWeight: FontWeight.bold)),
            ),
          );
        }),
      ),
    );
  }
}

/* ================= PODIUM ================= */

class _TopPodium extends StatelessWidget {
  final List<RankingEntry> data;
  final Color accent;

  const _TopPodium({required this.data, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      if (data.isNotEmpty) _Top1(entry: data[0], accent: accent),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(
            child: data.length > 1
                ? _TopMini(entry: data[1], accent: accent, label: 'TOP 2')
                : const SizedBox()),
        const SizedBox(width: 12),
        Expanded(
            child: data.length > 2
                ? _TopMini(entry: data[2], accent: accent, label: 'TOP 3')
                : const SizedBox()),
      ])
    ]);
  }
}

class _Top1 extends StatelessWidget {
  final RankingEntry entry;
  final Color accent;

  const _Top1({required this.entry, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.44,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: LinearGradient(
              colors: [accent.withOpacity(0.95), Colors.white]),
        ),
        child: Column(children: [
          const Icon(Icons.emoji_events, size: 48, color: Colors.white),
          const SizedBox(height: 10),
          UserAvatarHelper.circleAvatar(
            userIdentification: entry.userId,
            displayName:
            entry.username?.isNotEmpty == true ? entry.username! : entry.userId,
            radius: 40,
          ),
          const SizedBox(height: 10),
          Text(
            entry.username?.isNotEmpty == true ? entry.username! : entry.userId,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                color: Colors.brown, fontWeight: FontWeight.bold),
          ),
          Text('${entry.value}',
              style: const TextStyle(color: Colors.black)),
        ]),
      ),
    );
  }
}

class _TopMini extends StatelessWidget {
  final RankingEntry entry;
  final Color accent;
  final String label;

  const _TopMini(
      {required this.entry, required this.accent, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
            colors: [accent.withOpacity(0.75), accent.withOpacity(0.35)]),
      ),
      child: Column(children: [
        Text(label,
            style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        UserAvatarHelper.circleAvatar(
          userIdentification: entry.userId,
          displayName:
          entry.username?.isNotEmpty == true ? entry.username! : entry.userId,
          radius: 26,
        ),
        const SizedBox(height: 6),
        Text(
          entry.username?.isNotEmpty == true ? entry.username! : entry.userId,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        Text('${entry.value}',
            style: const TextStyle(color: Colors.white)),
      ]),
    );
  }
}

/* ================= LIST ================= */

class _RankingList extends StatelessWidget {
  final List<RankingEntry> data;
  final Color accent;

  const _RankingList({required this.data, required this.accent});

  @override
  Widget build(BuildContext context) {
    if (data.length <= 3) return const SizedBox.shrink();

    final listData = data.sublist(3);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: listData.length,
      itemBuilder: (_, i) {
        final entry = listData[i];
        return _RankRow(
          rank: entry.rank,
          userId: entry.userId,
          username: entry.username,
          value: entry.value,
          accent: accent,
        );
      },
    );
  }
}

/* ================= RANK ROW ================= */

class _RankRow extends StatelessWidget {
  final int rank;
  final String userId;
  final String? username;
  final int value;
  final Color accent;

  const _RankRow(
      {required this.rank,
        required this.userId,
        required this.username,
        required this.value,
        required this.accent});

  @override
  Widget build(BuildContext context) {
    final displayName =
    (username?.trim().isNotEmpty == true) ? username! : userId;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
              colors: [accent.withOpacity(0.28), Colors.black45])),
      child: Row(children: [
        Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration:
            BoxDecoration(color: accent, borderRadius: BorderRadius.circular(6)),
            child: Text('$rank',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold))),
        const SizedBox(width: 10),
        UserAvatarHelper.circleAvatar(
          userIdentification: userId,
          displayName: displayName,
          radius: 20,
        ),
        const SizedBox(width: 10),
        Expanded(
            child: Text(displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white))),
        Text('$value',
            style: const TextStyle(
                color: Colors.amber, fontWeight: FontWeight.bold)),
      ]),
    );
  }
}
