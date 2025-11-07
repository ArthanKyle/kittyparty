import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/global_widgets/gradient_background/gradient_background.dart';
import '../landing_widgets/post_widgets/create_post_page.dart';
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
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PostViewModel()..fetchPosts(),
      child: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
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
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {
                        // open create post page
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const CreatePostPage()),
                        );
                      },
                      icon: const Icon(Icons.add, color: Colors.black87),
                    ),
                    IconButton(
                      onPressed: () {}, // search
                      icon: const Icon(Icons.search, color: Colors.black87),
                    ),
                  ],
                ),
              ),
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
        ),
      ),
    );
  }
}
