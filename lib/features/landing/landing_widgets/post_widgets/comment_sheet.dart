import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/post_viewmodel.dart';
import '../../model/post.dart';

class CommentSheet extends StatelessWidget {
  final Post post;

  const CommentSheet({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<PostViewModel>(context, listen: false);
    final TextEditingController commentCtrl = TextEditingController();

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
            // --- HEADER ---
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

            // --- COMMENT LIST ---
            Expanded(
              child: FutureBuilder(
                future: vm.getComments(post.id),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final comments = snapshot.data as List<dynamic>;

                  if (comments.isEmpty) {
                    return const Center(
                      child: Text("No comments yet."),
                    );
                  }

                  return ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final c = comments[index];

                      return ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(c["content"] ?? ""),
                        subtitle: Text("User ${c["user"]}"),
                      );
                    },
                  );
                },
              ),
            ),

            // --- INPUT AREA ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: Colors.grey.shade100,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: commentCtrl,
                      decoration: InputDecoration(
                        hintText: "Write a comment...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.blueAccent),
                    onPressed: () async {
                      if (commentCtrl.text.trim().isEmpty) return;

                      await vm.addComment(
                        post.id,
                        commentCtrl.text.trim(),
                      );

                      Navigator.pop(context); // close sheet
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => CommentSheet(post: post),
                      );
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
