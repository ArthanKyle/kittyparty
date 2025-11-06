class Social {
  final int user;
  final List<int> following;
  final List<int> fans;
  final List<int> friends;
  final List<int> visitors;

  Social({
    required this.user,
    required this.following,
    required this.fans,
    required this.friends,
    required this.visitors,
  });

  factory Social.fromJson(Map<String, dynamic> json) {
    return Social(
      user: json['user'] ?? 0,
      following: List<int>.from(json['following'] ?? []),
      fans: List<int>.from(json['fans'] ?? []),
      friends: List<int>.from(json['friends'] ?? []),
      visitors: List<int>.from(json['visitors'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user,
      'following': following,
      'fans': fans,
      'friends': friends,
      'visitors': visitors,
    };
  }

  /// Simple counts for display
  Map<String, String> get counts => {
    'Following': following.length.toString(),
    'Fans': fans.length.toString(),
    'Friends': friends.length.toString(),
    'Visitors': visitors.length.toString(),
  };
}
