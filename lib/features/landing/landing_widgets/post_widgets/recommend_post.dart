import 'package:flutter/material.dart';
import 'package:kittyparty/features/landing/landing_widgets/post_widgets/recommend_post_item.dart';
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
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: vm.posts.length,
      itemBuilder: (ctx, i) {
        final p = vm.posts[i];
        return RecommendPostItem(post: p);
      },
    );
  }
}
