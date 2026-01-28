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
      userIdentification: json['UserIdentification'] ?? '',
      bio: json['bio'] ?? '',
      profilePicture: json['ProfilePicture'],

      // ✅ SAFE PARSING
      birthday: json['birthday']?.toString(),

      album: (json['album'] is List)
          ? List<String>.from(json['album'])
          : const [],
    );
  }
}
