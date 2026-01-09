class MallItem {
  final String id;
  final String name;
  final String assetPath;
  final int price;
  final int vipRequired;
  final String category;

  MallItem({
    required this.id,
    required this.name,
    required this.assetPath,
    required this.price,
    required this.vipRequired,
    required this.category,
  });

  factory MallItem.fromJson(Map<String, dynamic> json) {
    return MallItem(
      id: json['_id'],
      name: json['name'],
      assetPath: json['assetPath'],
      price: json['price'],
      vipRequired: json['vipRequired'],
      category: json['category'],
    );
  }
}
