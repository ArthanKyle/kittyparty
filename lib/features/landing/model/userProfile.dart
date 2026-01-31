class UserProfile {
  final String userIdentification; // numeric ID
  final String bio;
  final String? profilePicture;

  // ✅ ADD THESE
  final String? birthday;
  final List<String> album;

  UserProfile({
    required this.userIdentification,
    required this.bio,
    this.profilePicture,
    this.birthday,
    List<String>? album,
  }) : album = album ?? const [];

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userIdentification: json['UserID'] ?? '',
      bio: json['Bio'] ?? '',
      profilePicture: json['ProfilePicture'],
      birthday: json['Birthday'],
      album: (json['Album'] is List)
          ? List<String>.from(json['Album'])
          : const [],
    );
  }
}
