class RankingEntry {
  final int rank;
  final String userId;
  final int value;
  final int? level;

  RankingEntry({
    required this.rank,
    required this.userId,
    required this.value,
    this.level,
  });

  factory RankingEntry.fromJson(Map<String, dynamic> json) {
    return RankingEntry(
      rank: json['rank'],
      userId: json['userId'],
      value: (json['value'] as num).toInt(),
      level: json['level'],
    );
  }
}
