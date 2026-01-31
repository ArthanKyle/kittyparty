class BannerItem {
  final String id;
  final String image; // /assets/banner/xxx.jpg
  final String? route; // backend route key
  final bool enabled;

  BannerItem({
    required this.id,
    required this.image,
    required this.route,
    required this.enabled,
  });

  factory BannerItem.fromJson(Map<String, dynamic> json) {
    return BannerItem(
      id: json['id'],
      image: json['image'],
      route: json['route'],
      enabled: json['enabled'] ?? true,
    );
  }
}
