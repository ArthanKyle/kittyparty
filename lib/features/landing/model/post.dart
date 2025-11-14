class Post {
  final String id;
  final String authorId;
  final String content;
  final List<dynamic> media;
  final int likesCount;
  final int commentsCount;
  final DateTime createdAt;

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
    // Safely extract author ID
    String authorId = '';
    if (json['author'] != null) {
      if (json['author'] is Map) {
        authorId = json['author']['_id'] ?? '';
      } else if (json['author'] is String) {
        authorId = json['author'];
      }
    }

    // Safely parse createdAt
    DateTime createdAt;
    if (json['createdAt'] != null) {
      createdAt = DateTime.tryParse(json['createdAt']) ?? DateTime.now();
    } else {
      createdAt = DateTime.now();
    }

    // Safely parse media, likes, comments
    final media = json['media'] is List ? List<dynamic>.from(json['media']) : <dynamic>[];
    final likesCount = json['likes'] is List ? json['likes'].length : 0;
    final commentsCount = json['comments'] is List ? json['comments'].length : 0;

    return Post(
      id: json['_id'] ?? '',
      authorId: authorId,
      content: json['content'] ?? '',
      media: media,
      likesCount: likesCount,
      commentsCount: commentsCount,
      createdAt: createdAt,
    );
  }
}
