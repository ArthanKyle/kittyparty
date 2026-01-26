class ConvertModel {
  final int coins;
  final int diamonds;

  ConvertModel({
    required this.coins,
    required this.diamonds,
  });

  factory ConvertModel.fromJson(Map<String, dynamic> json) {
    return ConvertModel(
      coins: (json['coins'] as num?)?.toInt() ?? 0,
      diamonds: (json['diamonds'] as num?)?.toInt() ?? 0,
    );
  }
}
