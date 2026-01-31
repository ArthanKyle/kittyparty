class MallItem {
  final String id;
  final String name;
  final String sku;

  final String assetKey;
  final String assetType;

  final String png;
  final String svga;

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
    required this.png,
    required this.svga,
    required this.priceCoins,
    this.giftPriceCoins,
    this.durationDays,
    this.giftDurationDays,
  });

  factory MallItem.fromJson(Map<String, dynamic> json) {
    return MallItem(
      id: json['_id'],
      name: json['name'],
      sku: json['sku'],

      assetKey: json['assetKey'],
      assetType: json['assetType'],

      png: json['assets']['png'],
      svga: json['assets']['svga'],

      priceCoins: json['priceCoins'],
      giftPriceCoins: json['giftPriceCoins'],
      durationDays: json['durationDays'],
      giftDurationDays: json['giftDurationDays'],
    );
  }
}
