class TransactionModel {
  final String id;
  final String userId;
  final String? paymentIntentId;
  final String? clientSecret;
  final String paymentMethod;
  final String status;
  final double amount; // local currency
  final String currency;
  final int coinsBase;
  final int coinsBonus;
  final int coinsFinal;
  final String transactionRef;
  final String? providerId;
  final DateTime createdAt;
  final DateTime updatedAt;

  TransactionModel({
    required this.id,
    required this.userId,
    this.paymentIntentId,
    this.clientSecret,
    required this.paymentMethod,
    required this.status,
    required this.amount,
    required this.currency,
    required this.coinsBase,
    required this.coinsBonus,
    required this.coinsFinal,
    required this.transactionRef,
    this.providerId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['_id'],
      userId: json['userId'],
      paymentIntentId: json['paymentIntentId'],
      clientSecret: json['clientSecret'],
      paymentMethod: json['paymentMethod'] ?? 'card',
      status: json['status'] ?? 'pending',
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'],
      coinsBase: json['coinsBase'] ?? 0,
      coinsBonus: json['coinsBonus'] ?? 0,
      coinsFinal: json['coinsFinal'] ?? 0,
      transactionRef: json['transactionRef'],
      providerId: json['providerId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'paymentIntentId': paymentIntentId,
      'clientSecret': clientSecret,
      'paymentMethod': paymentMethod,
      'status': status,
      'amount': amount,
      'currency': currency,
      'coinsBase': coinsBase,
      'coinsBonus': coinsBonus,
      'coinsFinal': coinsFinal,
      'transactionRef': transactionRef,
      'providerId': providerId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
