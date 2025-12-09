class Post {
  final String id;
  final String content;
  final DateTime createdAt;

  final String authorId;
  final String authorUsername;
  final String authorFullName;
  final String? authorAvatarUrl;

  final List<dynamic> media;
  int likesCount;
  int commentsCount;

  Post({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.authorId,
    required this.authorUsername,
    required this.authorFullName,
    required this.authorAvatarUrl,
    required this.media,
    required this.likesCount,
    required this.commentsCount,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    final author = json['author'] ?? {};

    return Post(
      id: json['_id'] ?? "",
      content: json['content'] ?? "",
      createdAt: DateTime.tryParse(json['createdAt'] ?? "") ?? DateTime.now(),

      authorId: author['UserIdentification']?.toString() ?? "",
      authorUsername: author['Username'] ?? "",
      authorFullName: author['FullName'] ?? "",
      authorAvatarUrl: author['AvatarUrl'], // "/api/userprofiles/29862/profile-picture"

      media: json['media'] ?? [],

      likesCount: json['likesCount'] ?? 0,
      commentsCount: json['commentsCount'] ?? 0,
    );
  }
}
