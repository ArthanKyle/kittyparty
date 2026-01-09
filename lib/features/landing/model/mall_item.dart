class MallItem {
  final String id;
  final String name;
  final String sku;
  final String assetKey;
  final String category;

  final int priceCoins;
  final int? durationDays;
  final int? giftPriceCoins;
  final int? giftDurationDays;
  final bool isActive;

  MallItem({
    required this.id,
    required this.name,
    required this.sku,
    required this.assetKey,
    required this.category,
    required this.priceCoins,
    this.durationDays,
    this.giftPriceCoins,
    this.giftDurationDays,
    this.isActive = true,
  });

  factory MallItem.fromJson(Map<String, dynamic> json) {
    return MallItem(
      id: json['_id'],
      name: json['name'],
      sku: json['sku'],
      assetKey: json['assetKey'] ?? '', // safe
      category: json['category'],
      priceCoins: json['priceCoins'],
      durationDays: json['durationDays'],
      giftPriceCoins: json['giftPriceCoins'],
      giftDurationDays: json['giftDurationDays'],
      isActive: json['isActive'] ?? true,
    );
  }
}
