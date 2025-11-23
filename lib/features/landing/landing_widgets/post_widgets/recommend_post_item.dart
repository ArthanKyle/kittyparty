import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/user_provider.dart';
import '../../model/post.dart';

class RecommendPostItem extends StatelessWidget {
  final Post post;

  const RecommendPostItem({super.key, required this.post});

  // Safe URL fixer
  String fixUrl(String? url) {
    if (url == null || url.isEmpty) return "";
    if (url.startsWith("http")) return url;

    const base = "https://kittypartybackend-production.up.railway.app";
    return "$base$url";
  }

  // Safe profile picture builder from ObjectId (ProfilePicture)
  String profilePictureUrl(String? id) {
    if (id == null || id.isEmpty) return "";
    return "https://kittypartybackend-production.up.railway.app/profile/picture/$id";
  }

  @override
  Widget build(BuildContext context) {
    final media = post.media;

    final displayName = post.authorFullName.isNotEmpty
        ? post.authorFullName
        : post.authorUsername.isNotEmpty
        ? post.authorUsername
        : "User ${post.authorId}";

    final userProvider = Provider.of<UserProvider>(context);
    final isMyPost = post.authorId == userProvider.currentUser?.id;

    ImageProvider? avatarImage;

    // Pull sources
    final myBytes = userProvider.profilePictureBytes;
    final myUrl = userProvider.profilePictureUrl;
    final otherPicId = post.profilePictureId ?? "";

    // ----------------------------------------------------------------
    // COMPREHENSIVE SAFE AVATAR SELECTION (NO NULL CRASHING ANYWHERE)
    // ----------------------------------------------------------------
    if (isMyPost) {
      if (myBytes != null) {
        avatarImage = MemoryImage(myBytes);
      } else if (myUrl != null && myUrl.isNotEmpty) {
        avatarImage = NetworkImage(fixUrl(myUrl));
      }
    } else {
      if (otherPicId.isNotEmpty) {
        avatarImage = NetworkImage(profilePictureUrl(otherPicId));
      }
    }

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
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -----------------------------
            // HEADER
            // -----------------------------
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

            // -----------------------------
            // CAPTION
            // -----------------------------
            if (post.content.isNotEmpty)
              Text(
                post.content,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),

            const SizedBox(height: 8),

            // -----------------------------
            // MEDIA IMAGE
            // -----------------------------
            if (media.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  fixUrl(media.first['url'] ?? ''),
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

            // -----------------------------
            // ACTIONS
            // -----------------------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.favorite,
                        size: 20, color: Colors.pinkAccent),
                    const SizedBox(width: 4),
                    Text("${post.likesCount}"),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.comment,
                        size: 20, color: Colors.blueAccent),
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
