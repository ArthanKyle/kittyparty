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
        await context.read<PostViewModel>().fetchRecommendedPosts();
        _loaded = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final vm = context.watch<PostViewModel>();

    if (vm.loadingRecommended && !_loaded) {
      return const Center(child: CircularProgressIndicator());
    }

    final list = vm.recommendedPosts;

    return RefreshIndicator(
      onRefresh: () => vm.fetchRecommendedPosts(),
      child: list.isEmpty
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
        itemCount: list.length,
        itemBuilder: (_, i) => RecommendPostItem(post: list[i]),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
