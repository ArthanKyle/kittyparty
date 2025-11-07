import 'package:flutter/material.dart';
import 'package:kittyparty/features/landing/landing_widgets/post_widgets/recommend_post_item.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/user_provider.dart';
import '../../viewmodel/post_viewmodel.dart';
import 'recommend_post.dart';

class FollowingPostTab extends StatefulWidget {
  const FollowingPostTab({super.key});

  @override
  State<FollowingPostTab> createState() => _FollowingPostTabState();
}

class _FollowingPostTabState extends State<FollowingPostTab> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<UserProvider>().currentUser;
      if (user != null) {
        context.read<PostViewModel>().fetchFollowingPosts(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PostViewModel>();

    if (vm.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.posts.isEmpty) {
      return const Center(
        child: Text(
          "No posts from followed users",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        final user = context.read<UserProvider>().currentUser;
        if (user != null) {
          await context.read<PostViewModel>().fetchFollowingPosts(user.id);
        }
      },
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: vm.posts.length,
        itemBuilder: (_, i) => RecommendPostItem(post: vm.posts[i]),
      ),
    );
  }
}
