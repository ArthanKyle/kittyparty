class Post {
  final String id;
  final String authorId;
  final String content;
  final List<PostMedia> media;
  final int likesCount;
  final int commentsCount;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.authorId,
    required this.content,
    required this.media,
    required this.likesCount,
    required this.commentsCount,
    required this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['_id'] ?? json['id'] ?? '',
      authorId: json['author'] is Map ? (json['author']['_id'] ?? '') : (json['author'] ?? ''),
      content: json['content'] ?? '',
      media: (json['media'] as List<dynamic>? ?? [])
          .map((m) => PostMedia.fromJson(m as Map<String, dynamic>))
          .toList(),
      likesCount: json['likesCount'] ?? (json['likes'] != null ? (json['likes'] as List).length : 0),
      commentsCount: json['commentsCount'] ?? (json['comments'] != null ? (json['comments'] as List).length : 0),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class PostMedia {
  final String id;
  final String url;
  final String type;
  PostMedia({required this.id, required this.url, required this.type});

  factory PostMedia.fromJson(Map<String, dynamic> json) {
    return PostMedia(
      id: json['_id'] ?? json['id'] ?? '',
      url: json['url'] ?? json['path'] ?? '',
      type: json['type'] ?? 'image',
    );
  }
}
