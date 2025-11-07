import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../model/post.dart';

class RecommendPostItem extends StatelessWidget {
  final Post post;

  const RecommendPostItem({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final media = post.media ?? [];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header ---
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primaryLight,
                  child: Text(
                    post.authorId.isNotEmpty
                        ? post.authorId.substring(0, 1).toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "User ${post.authorId.substring(0, 6)}", // temporary placeholder
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                const Icon(Icons.more_vert, color: Colors.grey),
              ],
            ),

            const SizedBox(height: 10),

            // --- Caption / Content ---
            if (post.content.isNotEmpty)
              Text(
                post.content,
                style: const TextStyle(fontSize: 15, color: Colors.black87),
              ),

            const SizedBox(height: 8),

            // --- Media Preview ---
            if (media.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  media.first['url'] ?? '',
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 220,
                    width: double.infinity,
                    color: Colors.grey.shade200,
                    alignment: Alignment.center,
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),

            const SizedBox(height: 10),

            // --- Action Row ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.favorite, size: 20, color: Colors.pinkAccent),
                    const SizedBox(width: 4),
                    Text("${post.likesCount}"),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.comment, size: 20, color: Colors.blueAccent),
                    const SizedBox(width: 4),
                    Text("${post.commentsCount}"),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
