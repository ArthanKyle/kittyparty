class Post {
  final String id;

  final String authorId;
  final String authorUsername;
  final String authorFullName;
  final String authorAvatar;

  final String? profilePictureId;   // <-- NULLABLE

  final String content;
  final List<dynamic> media;

  final int likesCount;
  final int commentsCount;

  final DateTime createdAt;

  Post({
    required this.id,
    required this.authorId,
    required this.authorUsername,
    required this.authorFullName,
    required this.authorAvatar,
    required this.profilePictureId,   // <-- NULLABLE HERE TOO
    required this.content,
    required this.media,
    required this.likesCount,
    required this.commentsCount,
    required this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    final author = json['author'] ?? {};

    return Post(
      id: json['_id'] ?? '',
      authorId: author['UserIdentification']?.toString() ?? '',
      authorUsername: author['Username'] ?? '',
      authorFullName: author['FullName'] ?? '',
      authorAvatar: author['AvatarUrl'] ?? '',

      // --- THE REAL FIX ---
      profilePictureId: author['ProfilePicture']?.toString(),  // <-- CAN BE NULL

      content: json['content'] ?? '',
      media: json['media'] ?? [],
      likesCount: json['likesCount'] ?? 0,
      commentsCount: json['commentsCount'] ?? 0,
      createdAt:
      DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
