class RankingEntry {
  final int rank;
  final String userId;
  final String username;
  final int value;
  final int? level;

  RankingEntry({
    required this.rank,
    required this.userId,
    required this.username,
    required this.value,
    this.level,
  });

  factory RankingEntry.fromJson(Map<String, dynamic> json) {
    return RankingEntry(
      rank: json['rank'],
      userId: json['userId'],
      username: json['username'],
      value: json['value'],
      level: json['level'],
    );
  }
}
