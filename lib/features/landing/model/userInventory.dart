class UserInventoryItem {
  final String id;
  final String sku;
  final String source;
  final bool equipped;
  final DateTime acquiredAt;
  final DateTime? expiresAt;

  // 🔥 SNAPSHOT FIELDS (NON-NULL)
  final String assetType;
  final String assetKey;

  UserInventoryItem({
    required this.id,
    required this.sku,
    required this.source,
    required this.equipped,
    required this.acquiredAt,
    required this.assetType,
    required this.assetKey,
    this.expiresAt,
  });

  factory UserInventoryItem.fromJson(Map<String, dynamic> json) {
    return UserInventoryItem(
      id: json['_id'],
      sku: json['sku'],
      source: json['source'] ?? 'mall',
      equipped: json['equipped'] == true,
      acquiredAt: DateTime.parse(json['acquiredAt']),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'])
          : null,

      // 🔒 HARD GUARANTEE (API PROVIDES THESE)
      assetType: json['assetType'],
      assetKey: json['assetKey'],
    );
  }

  /// ✅ REQUIRED BY VIEWMODEL
  UserInventoryItem copyWith({
    bool? equipped,
  }) {
    return UserInventoryItem(
      id: id,
      sku: sku,
      source: source,
      equipped: equipped ?? this.equipped,
      acquiredAt: acquiredAt,
      expiresAt: expiresAt,
      assetType: assetType,
      assetKey: assetKey,
    );
  }
}
