import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/post_viewmodel.dart';
import '../../landing_widgets/post_widgets/recommend_post_item.dart';

class FollowingPostTab extends StatefulWidget {
  const FollowingPostTab({super.key});

  @override
  State<FollowingPostTab> createState() => _FollowingPostTabState();
}

class _FollowingPostTabState extends State<FollowingPostTab>
    with AutomaticKeepAliveClientMixin {
  bool _loaded = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!_loaded) {
        await context.read<PostViewModel>().fetchFollowingPosts();
        _loaded = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final vm = context.watch<PostViewModel>();

    if (vm.loadingFollowing && !_loaded) {
      return const Center(child: CircularProgressIndicator());
    }

    final list = vm.followingPosts;

    return RefreshIndicator(
      onRefresh: () => vm.fetchFollowingPosts(),
      child: list.isEmpty
          ? ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 200),
          Center(child: Text("No posts from followed users")),
        ],
      )
          : ListView.builder(
        itemCount: list.length,
        itemBuilder: (_, index) {
          final post = list[index];
          return RecommendPostItem(post: post);
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
