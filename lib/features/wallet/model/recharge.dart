class RechargePackage {
  final int coins;
  final int bonus;
  final double price;
  final String currency;
  final String symbol;

  RechargePackage({
    required this.coins,
    required this.bonus,
    required this.price,
    required this.currency,
    required this.symbol,
  });

  factory RechargePackage.fromJson(Map<String, dynamic> json) {
    return RechargePackage(
      coins: json['coins'] ?? 0,
      bonus: json['bonus'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'php',
      symbol: json['symbol'] ?? '₱',
    );
  }

  @override
  String toString() {
    return 'RechargePackage(coins: $coins, bonus: $bonus, price: $price, currency: $currency, symbol: $symbol)';
  }
}
