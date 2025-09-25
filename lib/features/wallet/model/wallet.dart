class Wallet {
  int coins;

  Wallet({required this.coins});

  factory Wallet.fromJson(Map<String, dynamic> json) {
    final raw = json['Coins'];
    return Wallet(
      coins: (raw is int)
          ? raw
          : int.tryParse(raw?.toString() ?? "0") ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'Coins': coins,
  };
}