import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/global_widgets/gradient_background/gradient_background.dart';
import '../landing_widgets/landing_widgets/mine_tab.dart';
import '../landing_widgets/landing_widgets/recommend_tab.dart';
import '../viewmodel/landing_viewmodel.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});
  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with SingleTickerProviderStateMixin {
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
    return GradientBackground(
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
                      offset: const Offset(-45, 0), // nudges TabBar 8px left
                      child: Material(
                        color: Colors.transparent, // removes white line background
                        child: TabBar(
                          controller: _tab,
                          isScrollable: true,
                          labelPadding: const EdgeInsets.only(right: 24),
                          indicatorSize: TabBarIndicatorSize.label,
                          dividerColor: Colors.transparent, // hides thin divider line
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.black45,
                          labelStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                          tabs: const [
                            Tab(text: 'Recommend'),
                            Tab(text: 'Mine'),
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
                children: [
                  const RecommendTab(),
                  ChangeNotifierProvider(
                    create: (_) => LandingViewModel(),
                    child: const MineTab(),
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