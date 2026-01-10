// lib/features/landing/model/userInventory.dart

class UserInventoryItem {
  final String id;
  final String sku;
  final String source;
  final bool equipped;
  final DateTime acquiredAt;
  final DateTime? expiresAt;

  final String? assetKey;
  final String? category;

  UserInventoryItem({
    required this.id,
    required this.sku,
    required this.source,
    required this.equipped,
    required this.acquiredAt,
    this.expiresAt,
    this.assetKey,
    this.category,
  });

  factory UserInventoryItem.fromJson(Map<String, dynamic> json) {
    final item = json['itemId'];

    return UserInventoryItem(
      id: json['_id'],
      sku: json['sku'],
      source: json['source'],
      equipped: json['equipped'] == true,
      acquiredAt: DateTime.parse(json['acquiredAt']),
      expiresAt:
      json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
      assetKey: item?['assetKey'],
      category: item?['category'],
    );
  }

  /// ✅ REQUIRED BY VIEWMODEL
  UserInventoryItem copyWith({bool? equipped}) {
    return UserInventoryItem(
      id: id,
      sku: sku,
      source: source,
      equipped: equipped ?? this.equipped,
      acquiredAt: acquiredAt,
      expiresAt: expiresAt,
      assetKey: assetKey,
      category: category,
    );
  }

  /// ✅ SINGLE SOURCE OF TRUTH FOR IMAGE
  String? get assetPath {
    if (assetKey == null || category == null) return null;

    switch (category!.toLowerCase()) {
      case 'avatar':
        return 'assets/image/avatar/$assetKey.png';
      case 'mount':
      default:
        return 'assets/image/rides/$assetKey.png';
    }
  }
}
