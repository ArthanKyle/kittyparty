class DailyTask {
  final String key;
  final String title;
  final String? subtitle;

  final int reward;
  final int target;
  final int progress;

  // Backend returns these
  final bool completed; // claimed/completed flag stored in UserTask
  final bool rewarded;  // reward claimed (true when coins already granted)

  final DateTime? lastClaimedAt;

  DailyTask({
    required this.key,
    required this.title,
    this.subtitle,
    required this.reward,
    required this.target,
    required this.progress,
    required this.completed,
    required this.rewarded,
    this.lastClaimedAt,
  });

  factory DailyTask.fromJson(Map<String, dynamic> json) {
    return DailyTask(
      key: (json['key'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      subtitle: json['subtitle']?.toString(),
      reward: _toInt(json['reward']),
      target: _toInt(json['target']),
      progress: _toInt(json['progress']),
      completed: (json['completed'] ?? false) == true,
      rewarded: (json['rewarded'] ?? false) == true,
      lastClaimedAt: json['lastClaimedAt'] != null
          ? DateTime.tryParse(json['lastClaimedAt'].toString())
          : null,
    );
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse((v ?? '0').toString()) ?? 0;
  }
}
