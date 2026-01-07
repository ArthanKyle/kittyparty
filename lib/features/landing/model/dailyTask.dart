class DailyTask {
  final String key;
  final String title;
  final String? subtitle;
  final int reward;
  final int target;
  final int progress;
  final bool completed;
  final bool rewarded;
  final String? lastClaimedAt;

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
      key: json['key']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString(),
      reward: (json['reward'] ?? 0) is int ? json['reward'] : int.tryParse('${json['reward']}') ?? 0,
      target: (json['target'] ?? 0) is int ? json['target'] : int.tryParse('${json['target']}') ?? 0,
      progress: (json['progress'] ?? 0) is int ? json['progress'] : int.tryParse('${json['progress']}') ?? 0,
      completed: json['completed'] == true,
      rewarded: json['rewarded'] == true,
      lastClaimedAt: json['lastClaimedAt']?.toString(),
    );
  }
}
