import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/post_viewmodel.dart';
import 'recommend_post_item.dart';

class RecommendPost extends StatefulWidget {
  const RecommendPost({super.key});

  @override
  State<RecommendPost> createState() => _RecommendPostState();
}

class _RecommendPostState extends State<RecommendPost>
    with AutomaticKeepAliveClientMixin {

  bool _loaded = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!_loaded) {
        await context.read<PostViewModel>().fetchPosts();
        _loaded = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final vm = context.watch<PostViewModel>();

    // Show loading only on first load
    if (vm.loading && !_loaded) {
      return const Center(child: CircularProgressIndicator());
    }

    // Remove user's own posts
    final filtered = vm.posts.where((p) {
      return p.authorId != vm.currentUserId;
    }).toList();

    return RefreshIndicator(
      onRefresh: () => context.read<PostViewModel>().fetchPosts(),
      child: filtered.isEmpty
          ? ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 200),
          Center(child: Text("No recommended posts")),
        ],
      )
          : ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 80),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: filtered.length,
        itemBuilder: (_, i) => RecommendPostItem(post: filtered[i]),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
