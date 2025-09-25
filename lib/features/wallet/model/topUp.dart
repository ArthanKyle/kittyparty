class TopUp {
  final String id;
  final String userId;
  final String providerId;
  final double amount;
  final int coinsCredited;
  final String transactionRef;
  final DateTime createdAt;

  TopUp({
    required this.id,
    required this.userId,
    required this.providerId,
    required this.amount,
    required this.coinsCredited,
    required this.transactionRef,
    required this.createdAt,
  });

  factory TopUp.fromJson(Map<String, dynamic> json) => TopUp(
    id: json['_id'],
    userId: json['userId'],
    providerId: json['providerId'] ?? '',
    amount: (json['amount'] as num).toDouble(),
    coinsCredited: json['coinsCredited'],
    transactionRef: json['transactionRef'],
    createdAt: DateTime.parse(json['createdAt']),
  );
}
