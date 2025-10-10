class UserProfile {
  late final String userIdentification; // numeric ID
  final String bio;
  final String? profilePicture;

  UserProfile({
    required this.userIdentification,
    required this.bio,
    this.profilePicture,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userIdentification: json['UserIdentification'] ?? '',
      bio: json['bio'] ?? '',
      profilePicture: json['ProfilePicture'],
    );
  }
}
