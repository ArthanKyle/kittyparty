class RechargeTxn {
  final String id;
  final String status;
  final double amount;
  final String currency;
  final int coinsBase;
  final int coinsBonus;
  final int coinsFinal;
  final String paymentMethod;
  final String transactionRef;
  final DateTime createdAt;

  RechargeTxn({
    required this.id,
    required this.status,
    required this.amount,
    required this.currency,
    required this.coinsBase,
    required this.coinsBonus,
    required this.coinsFinal,
    required this.paymentMethod,
    required this.transactionRef,
    required this.createdAt,
  });

  static int _toInt(dynamic v) => (v is num) ? v.toInt() : int.tryParse("${v ?? 0}") ?? 0;
  static double _toDouble(dynamic v) => (v is num) ? v.toDouble() : double.tryParse("${v ?? 0}") ?? 0.0;

  static DateTime _toDate(dynamic v) {
    final s = (v ?? "").toString();
    return DateTime.tryParse(s)?.toLocal() ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  factory RechargeTxn.fromJson(Map<String, dynamic> j) {
    return RechargeTxn(
      id: (j["_id"] ?? j["id"] ?? "").toString(),
      status: (j["status"] ?? "").toString(),
      amount: _toDouble(j["amount"]),
      currency: (j["currency"] ?? "").toString(),
      coinsBase: _toInt(j["coinsBase"]),
      coinsBonus: _toInt(j["coinsBonus"]),
      coinsFinal: _toInt(j["coinsFinal"]),
      paymentMethod: (j["paymentMethod"] ?? "").toString(),
      transactionRef: (j["transactionRef"] ?? "").toString(),
      createdAt: _toDate(j["createdAt"]),
    );
  }
}
