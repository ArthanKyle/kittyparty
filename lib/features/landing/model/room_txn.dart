class RoomIncomeSummary {
  final String roomId;
  final int contributionTodayCoins;
  final int contributionTotalCoins;
  final int dailyRewardTierPaid;
  final DateTime? lastResetAt;
  final List<RoomIncomeLogItem> recent;

  RoomIncomeSummary({
    required this.roomId,
    required this.contributionTodayCoins,
    required this.contributionTotalCoins,
    required this.dailyRewardTierPaid,
    required this.lastResetAt,
    required this.recent,
  });

  static int _toInt(dynamic v) => (v is num) ? v.toInt() : int.tryParse("${v ?? 0}") ?? 0;

  static DateTime? _toDateOrNull(dynamic v) {
    if (v == null) return null;
    final s = v.toString();
    return DateTime.tryParse(s)?.toLocal();
  }

  factory RoomIncomeSummary.fromJson(Map<String, dynamic> j) {
    final recentRaw = (j["recent"] is List) ? (j["recent"] as List) : const [];
    return RoomIncomeSummary(
      roomId: (j["roomId"] ?? "").toString(),
      contributionTodayCoins: _toInt(j["contributionTodayCoins"]),
      contributionTotalCoins: _toInt(j["contributionTotalCoins"]),
      dailyRewardTierPaid: _toInt(j["dailyRewardTierPaid"]),
      lastResetAt: _toDateOrNull(j["lastResetAt"]),
      recent: recentRaw
          .whereType<Map>()
          .map((e) => RoomIncomeLogItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

class RoomIncomeLogItem {
  final String id;
  final String eventType;
  final int amountCoins;
  final String? senderId;
  final String? receiverId;
  final Map<String, dynamic> meta;
  final DateTime createdAt;

  RoomIncomeLogItem({
    required this.id,
    required this.eventType,
    required this.amountCoins,
    required this.senderId,
    required this.receiverId,
    required this.meta,
    required this.createdAt,
  });

  static int _toInt(dynamic v) => (v is num) ? v.toInt() : int.tryParse("${v ?? 0}") ?? 0;

  static DateTime _toDate(dynamic v) {
    final s = (v ?? "").toString();
    return DateTime.tryParse(s)?.toLocal() ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  factory RoomIncomeLogItem.fromJson(Map<String, dynamic> j) {
    return RoomIncomeLogItem(
      id: (j["_id"] ?? j["id"] ?? "").toString(),
      eventType: (j["EventType"] ?? j["eventType"] ?? "").toString(),
      amountCoins: _toInt(j["AmountCoins"] ?? j["amountCoins"]),
      senderId: (j["SenderID"] ?? j["senderId"])?.toString(),
      receiverId: (j["ReceiverID"] ?? j["receiverId"])?.toString(),
      meta: (j["Meta"] is Map<String, dynamic>)
          ? (j["Meta"] as Map<String, dynamic>)
          : (j["meta"] is Map<String, dynamic>)
          ? (j["meta"] as Map<String, dynamic>)
          : <String, dynamic>{},
      createdAt: _toDate(j["createdAt"]),
    );
  }
}
