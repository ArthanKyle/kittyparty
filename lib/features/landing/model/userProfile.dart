class UserProfile {
  final String userId;
  final String? profilePicture;
  final String bio;

  UserProfile({
    required this.userId,
    this.profilePicture,
    this.bio = "",
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    userId: json['UserID'] as String,
    profilePicture: json['ProfilePicture'] as String?,
    bio: json['Bio'] as String? ?? "",
  );

  Map<String, dynamic> toJson() => {
    'UserID': userId,
    'ProfilePicture': profilePicture,
    'Bio': bio,
  };
}