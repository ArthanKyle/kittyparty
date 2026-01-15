class TransactionModel {
  final String id;

  // 🔑 STRING IDENTIFIER (matches backend)
  final String userIdentification;

  final String? paymentIntentId;
  final String? clientSecret;
  final String paymentMethod;
  final String status;

  // 💰 Payment info
  final double amount; // local currency
  final String currency;

  // 🪙 Coins
  final int coinsBase;
  final int coinsBonus;
  final int coinsFinal;

  // 🔗 References
  final String transactionRef;
  final String? providerId;

  // ⏱️ Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;

  TransactionModel({
    required this.id,
    required this.userIdentification,
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
      id: json['_id'] as String,
      userIdentification: json['userIdentification'] as String,
      paymentIntentId: json['paymentIntentId'] as String?,
      clientSecret: json['clientSecret'] as String?,
      paymentMethod: json['paymentMethod'] ?? 'card',
      status: json['status'] ?? 'pending',
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      coinsBase: (json['coinsBase'] ?? 0) as int,
      coinsBonus: (json['coinsBonus'] ?? 0) as int,
      coinsFinal: (json['coinsFinal'] ?? 0) as int,
      transactionRef: json['transactionRef'] as String,
      providerId: json['providerId'] as String?,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userIdentification': userIdentification,
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
