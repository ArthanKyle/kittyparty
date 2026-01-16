class RewardItem {
  final String title;
  final String image;
  final String duration;
  final bool isPermanent;

  const RewardItem({
    required this.title,
    required this.image,
    this.duration = '',
    this.isPermanent = false,
  });
}
