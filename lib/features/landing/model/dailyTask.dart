class DailyTask {
  final String key;
  final String title;
  final String? subtitle;
  final int reward;
  final String rewardUnit;
  final int target;
  final int progress;
  final bool completed;

  DailyTask({
    required this.key,
    required this.title,
    this.subtitle,
    required this.reward,
    required this.rewardUnit,
    required this.target,
    required this.progress,
    required this.completed,
  });

  factory DailyTask.fromJson(Map<String, dynamic> json) {
    return DailyTask(
      key: json['key'],
      title: json['title'],
      subtitle: json['subtitle'],
      reward: json['reward'],
      rewardUnit: json['rewardUnit'],
      target: json['target'],
      progress: json['progress'],
      completed: json['completed'],
    );
  }
}
