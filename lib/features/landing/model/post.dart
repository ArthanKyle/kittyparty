class Post {
  final String id;
  final String authorId;
  final String content;
  final List<dynamic>? media;
  final int likesCount;
  final int commentsCount;
  final String createdAt;

  Post({
    required this.id,
    required this.authorId,
    required this.content,
    this.media,
    this.likesCount = 0,
    this.commentsCount = 0,
    required this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['_id'] ?? '',
      authorId: json['author'] is Map ? json['author']['_id'] ?? '' : json['author'] ?? '',
      content: json['content'] ?? '',
      media: json['media'] ?? [],
      likesCount: json['likesCount'] ?? (json['likes']?.length ?? 0),
      commentsCount: json['commentsCount'] ?? (json['comments']?.length ?? 0),
      createdAt: json['createdAt'] ?? '',
    );
  }
}
