import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/global_widgets/buttons/create_post_button.dart';
import '../../../core/global_widgets/gradient_background/gradient_background.dart';
import '../../../core/utils/user_provider.dart';
import '../viewmodel/post_viewmodel.dart';
import '../../landing/landing_widgets/post_widgets/recommend_post.dart';
import '../../landing/landing_widgets/post_widgets/following_post_tab.dart';

class PostPage extends StatefulWidget {
  const PostPage({super.key});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<PostViewModel>();

      if (vm.recommendedPosts.isEmpty && !vm.loadingRecommended) {
        vm.fetchRecommendedPosts();
      }
      if (vm.followingPosts.isEmpty && !vm.loadingFollowing) {
        vm.fetchFollowingPosts();
      }
    });
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final currentUser = userProvider.currentUser;

    if (currentUser == null) {
      return const Center(child: Text("No user loaded."));
    }

    return GradientBackground(
      child: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 20),

                // ✅ Header matches LandingPage layout (TabBar left + Search icon right)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 8, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Transform.translate(
                          offset: const Offset(-45, 0),
                          child: Material(
                            color: Colors.transparent,
                            child: TabBar(
                              controller: _tab,
                              isScrollable: true,
                              labelPadding: const EdgeInsets.only(right: 24),
                              indicatorSize: TabBarIndicatorSize.label,
                              dividerColor: Colors.transparent,
                              labelColor: Colors.white,
                              unselectedLabelColor: Colors.black45,
                              labelStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                              tabs: const [
                                Tab(text: 'Recommend'),
                                Tab(text: 'Following'),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),

                // Pages (swipe left/right)
                Expanded(
                  child: TabBarView(
                    controller: _tab,
                    children: const [
                      RecommendPost(),
                      FollowingPostTab(),
                    ],
                  ),
                ),
              ],
            ),

            // ✅ Keep your floating create button
            Positioned(
              bottom: 24,
              right: 24,
              child: CreatePostButton(
                icon: Icons.send,
                backgroundColor: Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
