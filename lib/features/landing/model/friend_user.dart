
class FriendUser {
  final String userIdentification;
  final String? username;
  final String? fullName;

  FriendUser({
    required this.userIdentification,
    this.username,
    this.fullName,
  });

  factory FriendUser.fromJson(Map<String, dynamic> json) {
    return FriendUser(
      userIdentification: json['UserIdentification'],
      username: json['Username'],
      fullName: json['FullName'],
    );
  }
}
