import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/post_viewmodel.dart';

class RecommendPost extends StatelessWidget {
  const RecommendPost({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<PostViewModel>(context);
    if (vm.loading) return const Center(child: CircularProgressIndicator());
    if (vm.posts.isEmpty) return const Center(child: Text('No posts yet'));
    return ListView.builder(
      itemCount: vm.posts.length,
      itemBuilder: (ctx, i) {
        final p = vm.posts[i];
        return ListTile(
          title: Text(p.content, maxLines: 2, overflow: TextOverflow.ellipsis),
          subtitle: Text('${p.likesCount} likes · ${p.commentsCount} comments'),
        );
      },
    );
  }
}
