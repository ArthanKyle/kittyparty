class RoomIncomeHistoryEntry {
  final String id;
  final String eventType;
  final int amountCoins;
  final String? senderId;
  final String? receiverId;
  final Map<String, dynamic> meta;
  final DateTime createdAt;

  RoomIncomeHistoryEntry({
    required this.id,
    required this.eventType,
    required this.amountCoins,
    required this.createdAt,
    this.senderId,
    this.receiverId,
    required this.meta,
  });

  factory RoomIncomeHistoryEntry.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v) {
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    return RoomIncomeHistoryEntry(
      id: json['_id'] as String,
      eventType: json['EventType'] as String,
      amountCoins: toInt(json['AmountCoins']),
      senderId: json['SenderID'],
      receiverId: json['ReceiverID'],
      meta: (json['Meta'] as Map?)?.cast<String, dynamic>() ?? {},
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
