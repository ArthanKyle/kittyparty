import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/utils/profile_picture_helper.dart';
import '../../../../core/utils/user_provider.dart';

import '../../model/post.dart';
import '../../viewmodel/post_viewmodel.dart';

import 'auto_media_widget.dart';
import 'comment_sheet.dart';
import 'user_profile_sheet.dart';

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

    final userProvider = context.watch<UserProvider>();
    final isMyPost =
        post.authorId == userProvider.currentUser?.userIdentification;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= HEADER =================
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (_) => UserProfileSheet(
                        userId: post.authorId,
                        displayName: displayName,
                        avatarUrl: post.authorAvatarUrl != null
                            ? "$base${post.authorAvatarUrl}"
                            : null,
                      ),
                    );
                  },
                  child: UserAvatarHelper.circleAvatar(
                    userIdentification: post.authorId,
                    displayName: displayName,
                    localBytes:
                    isMyPost ? userProvider.profilePictureBytes : null,
                    radius: 20,
                    frameAsset:null
                  ),
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
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  onPressed: () => _openMenu(context, isMyPost),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ================= CONTENT =================
            if (post.content.isNotEmpty)
              Text(
                post.content,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),

            const SizedBox(height: 10),

            // ================= MEDIA =================
            if (media.isNotEmpty)
              AutoMediaWidget(
                media: media.first,
                height: 220,
              ),

            const SizedBox(height: 10),

            // ================= ACTIONS =================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () async {
                    final vm = context.read<PostViewModel>();
                    final liked = await vm.hasLiked(post.id);
                    liked
                        ? vm.unlikePost(post.id)
                        : vm.likePost(post.id);
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.favorite,
                        size: 20,
                        color: post.likesCount > 0
                            ? Colors.pinkAccent
                            : Colors.grey,
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
                      const Icon(
                        Icons.comment,
                        size: 20,
                        color: Colors.blueAccent,
                      ),
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

  // ================= MENU =================
  void _openMenu(BuildContext context, bool isMyPost) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isMyPost) ...[
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text("Edit post"),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text("Delete post"),
                onTap: () async {
                  Navigator.pop(context);

                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("Delete post"),
                      content: const Text(
                        "Are you sure you want to delete this post?",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              Navigator.pop(context, false),
                          child: const Text("Cancel"),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () =>
                              Navigator.pop(context, true),
                          child: const Text(
                            "Delete",
                            style: TextStyle(
                              color: AppColors.accentWhite,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (ok == true) {
                    await context
                        .read<PostViewModel>()
                        .deletePost(post.id);
                  }
                },
              ),
            ] else
              ListTile(
                leading: const Icon(Icons.visibility_off),
                title: const Text("Hide post"),
                onTap: () {
                  Navigator.pop(context);
                  context.read<PostViewModel>().hidePost(post.id);
                },
              ),
          ],
        ),
      ),
    );
  }
}
