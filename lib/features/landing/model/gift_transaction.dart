class GiftTransaction {
  final String id;
  final String roomId;
  final String senderId;
  final String receiverId;

  final String giftId;
  final String giftName;
  final String giftAssetKey;

  final int giftCount;
  final String giftCategory;

  final int coinsSpent;
  final int diamondsReceived;
  final int coinsWon;
  final int? luckyMultiplier;

  final DateTime createdAt;

  GiftTransaction({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.receiverId,
    required this.giftId,
    required this.giftName,
    required this.giftAssetKey,
    required this.giftCount,
    required this.giftCategory,
    required this.coinsSpent,
    required this.diamondsReceived,
    required this.coinsWon,
    required this.luckyMultiplier,
    required this.createdAt,
  });

  factory GiftTransaction.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v) {
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    return GiftTransaction(
      id: json['_id']?.toString() ?? '',
      roomId: json['RoomID']?.toString() ?? '',
      senderId: json['SenderUserIdentification']?.toString() ?? '',
      receiverId: json['ReceiverUserIdentification']?.toString() ?? '',

      giftId: json['GiftID']?.toString() ?? '',
      giftName: json['GiftName']?.toString() ?? 'Unknown Gift',
      giftAssetKey: json['GiftAssetKey']?.toString() ?? '',

      giftCount: toInt(json['GiftCount']),
      giftCategory: json['GiftCategory']?.toString() ?? 'general',

      coinsSpent: toInt(json['CoinsSpent']),
      diamondsReceived: toInt(json['DiamondsReceived']),
      coinsWon: toInt(json['CoinsWon']),
      luckyMultiplier: json['LuckyMultiplier'] == null
          ? null
          : toInt(json['LuckyMultiplier']),

      createdAt: DateTime.tryParse(
        json['createdAt']?.toString() ?? '',
      ) ??
          DateTime.now(),
    );
  }
}
