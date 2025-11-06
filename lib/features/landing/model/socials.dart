class Social {
  final int user;
  final int following;
  final int fans;
  final int friends;
  final int visitors;

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
      following: json['following'] ?? 0,
      fans: json['fans'] ?? 0,
      friends: json['friends'] ?? 0,
      visitors: json['visitors'] ?? 0,
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

  /// Readable stats for UI
  Map<String, String> get counts => {
    'Following': following.toString(),
    'Fans': fans.toString(),
    'Friends': friends.toString(),
    'Visitors': visitors.toString(),
  };
}
