class GiftItem {
  final String id;
  final String name;
  final int price;
  final String png;
  final String svga;

  GiftItem({
    required this.id,
    required this.name,
    required this.price,
    required this.png,
    required this.svga,
  });

  factory GiftItem.fromJson(String id, Map<String, dynamic> json) {
    return GiftItem(
      id: id,
      name: json['name'],
      price: json['price'],
      png: json['assets']['png'],
      svga: json['assets']['svga'],
    );
  }

  /// ✅ SINGLE SOURCE OF TRUTH
  String get category {
    final prefix = id[0];

    switch (prefix) {
      case '2':
        return 'general';
      case '3':
        return 'lucky';
      case '4':
        return 'couple';
      case '5':
        return 'ride';
      case '6':
        return 'frame';
      case '7':
        return 'vip';
      default:
        return 'general';
    }
  }
}
