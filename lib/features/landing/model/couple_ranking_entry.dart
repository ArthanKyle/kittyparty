class CoupleRankingEntry {
  final int rank;
  final List<String> users;
  final int value;

  CoupleRankingEntry({
    required this.rank,
    required this.users,
    required this.value,
  });

  factory CoupleRankingEntry.fromJson(Map<String, dynamic> json) {
    return CoupleRankingEntry(
      rank: json['rank'],
      users: List<String>.from(json['users']),
      value: (json['value'] as num).toInt(),
    );
  }
}
