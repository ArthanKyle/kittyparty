class Wallet {
  final int coins;
  final int diamonds;

  const Wallet({
    required this.coins,
    required this.diamonds,
  });

  Wallet copyWith({
    int? coins,
    int? diamonds,
  }) {
    return Wallet(
      coins: coins ?? this.coins,
      diamonds: diamonds ?? this.diamonds,
    );
  }
}
