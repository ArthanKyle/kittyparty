import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/user_provider.dart';
import '../../model/post.dart';
import '../../viewmodel/post_viewmodel.dart';
import 'comment_sheet.dart';

class RecommendPostItem extends StatelessWidget {
  final Post post;

  const RecommendPostItem({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final base = dotenv.env['BASE_URL'] ?? "";
    final media = post.media;

    final displayName = post.authorUsername.isNotEmpty
        ? post.authorUsername
        : post.authorFullName.isNotEmpty
        ? post.authorFullName
        : "User ${post.authorId}";

    final userProvider = Provider.of<UserProvider>(context);
    final isMyPost = post.authorId == userProvider.currentUser?.userIdentification;

    ImageProvider? avatarImage;

    if (isMyPost) {
      final myBytes = userProvider.profilePictureBytes;
      final myUrl = userProvider.profilePictureUrl;

      if (myBytes != null) {
        avatarImage = MemoryImage(myBytes);
      } else if (myUrl != null && myUrl.isNotEmpty) {
        avatarImage = NetworkImage(myUrl);
      }
    } else {
      if (post.authorAvatarUrl != null) {
        avatarImage = NetworkImage("$base${post.authorAvatarUrl}");
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primaryLight,
                  backgroundImage: avatarImage,
                  child: avatarImage == null
                      ? Text(
                    displayName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    displayName,
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

            if (post.content.isNotEmpty)
              Text(
                post.content,
                style: const TextStyle(fontSize: 15, color: Colors.black87),
              ),

            const SizedBox(height: 8),

            if (media.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  "$base${media.first['url']}",
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 220,
                    color: Colors.grey.shade200,
                    alignment: Alignment.center,
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () async {
                    final vm = context.read<PostViewModel>();
                    final liked = await vm.hasLiked(post.id);
                    liked ? vm.unlikePost(post.id) : vm.likePost(post.id);
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.favorite,
                        size: 20,
                        color: post.likesCount > 0 ? Colors.pinkAccent : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text("${post.likesCount}"),
                    ],
                  ),
                ),

                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (_) => CommentSheet(post: post),
                    );
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.comment, size: 20, color: Colors.blueAccent),
                      const SizedBox(width: 4),
                      Text("${post.commentsCount}"),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
