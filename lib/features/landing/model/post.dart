class Post {
  final String id;
  final String authorId;
  final String content;
  final List<dynamic> media;
  final int likesCount;
  final int commentsCount;
  final String createdAt;

  Post({
    required this.id,
    required this.authorId,
    required this.content,
    this.media = const [],
    this.likesCount = 0,
    this.commentsCount = 0,
    required this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['_id'] ?? '',
      // If 'author' is a map, extract _id; otherwise use string
      authorId: json['author'] is Map ? json['author']['_id'] ?? '' : json['author'] ?? '',
      content: json['content'] ?? '',
      media: List<dynamic>.from(json['media'] ?? []),
      likesCount: (json['likes'] as List?)?.length ?? 0,
      commentsCount: (json['comments'] as List?)?.length ?? 0,
      createdAt: json['createdAt'] ?? '',
    );
  }
}
