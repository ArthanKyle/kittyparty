import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/profile_picture_helper.dart';
import '../../../../core/utils/user_provider.dart';
import '../../viewmodel/post_viewmodel.dart';
import '../../model/post.dart';

class CommentSheet extends StatefulWidget {
  final Post post;

  const CommentSheet({
    super.key,
    required this.post,
  });

  @override
  State<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet> {
  final TextEditingController commentCtrl = TextEditingController();
  late Future<List<dynamic>> commentsFuture;

  @override
  void initState() {
    super.initState();
    commentsFuture =
        context.read<PostViewModel>().getComments(widget.post.id);
  }

  @override
  void dispose() {
    commentCtrl.dispose();
    super.dispose();
  }

  void _refreshComments() {
    setState(() {
      commentsFuture =
          context.read<PostViewModel>().getComments(widget.post.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final postVm = context.read<PostViewModel>();
    final userProvider = context.watch<UserProvider>();

    final canComment =
        userProvider.currentUser?.userIdentification != null;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              height: 5,
              width: 45,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Comments",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),

            // ================= COMMENTS LIST =================
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: commentsFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final comments = snapshot.data!;
                  if (comments.isEmpty) {
                    return const Center(
                      child: Text("No comments yet."),
                    );
                  }

                  return ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final c = comments[index];
                      final author = c["author"] ?? {};

                      final userId = (author["UserIdentification"] ??
                          "unknown_user")
                          .toString();

                      final displayName = (author["Username"] ??
                          author["FullName"] ??
                          "User")
                          .toString();

                      return ListTile(
                        leading: UserAvatarHelper.circleAvatar(
                          userIdentification: userId,
                          displayName: displayName,
                          radius: 18,
                          frameUrl: null,
                        ),
                        title: Text(
                          displayName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          (c["content"] ?? "").toString(),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // ================= INPUT =================
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              color: Colors.grey.shade100,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: commentCtrl,
                      enabled: canComment,
                      decoration: InputDecoration(
                        hintText: canComment
                            ? "Write a comment..."
                            : "Login required",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.send,
                      color: Colors.blueAccent,
                    ),
                    onPressed: !canComment
                        ? null
                        : () {
                      final text = commentCtrl.text.trim();
                      if (text.isEmpty) return;

                      // 🔥 instant UX
                      commentCtrl.clear();

                      // 🔥 fire-and-forget send
                      postVm.addComment(widget.post.id, text);

                      // 🔥 refresh list so comment appears
                      _refreshComments();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
