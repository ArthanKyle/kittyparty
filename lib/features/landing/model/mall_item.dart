class MallItem {
  final String id;
  final String name;
  final String sku;
  final String assetKey;
  final String assetType;

  final int priceCoins;
  final int? giftPriceCoins;
  final int? durationDays;
  final int? giftDurationDays;

  MallItem({
    required this.id,
    required this.name,
    required this.sku,
    required this.assetKey,
    required this.assetType,
    required this.priceCoins,
    this.giftPriceCoins,
    this.durationDays,
    this.giftDurationDays,
  });

  factory MallItem.fromJson(Map<String, dynamic> json) {
    return MallItem(
      id: json['_id']?.toString() ?? '',
      name: json['name'] ?? '',
      sku: json['sku'] ?? '',
      assetKey: json['assetKey'] ?? '',
      assetType: json['assetType'] ?? '', // 👈 SAFE
      priceCoins: json['priceCoins'] ?? 0,
      giftPriceCoins: json['giftPriceCoins'],
      durationDays: json['durationDays'],
      giftDurationDays: json['giftDurationDays'],
    );
  }
}
