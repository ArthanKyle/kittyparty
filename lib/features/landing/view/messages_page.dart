import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/global_widgets/gradient_background/gradient_background.dart';
import '../landing_widgets/message_widgets/fans_tab.dart';
import '../landing_widgets/message_widgets/following_tab.dart';
import '../landing_widgets/message_widgets/friends_tab.dart';
import '../landing_widgets/message_widgets/message_tab.dart';



class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Tab> myTabs = const [
    Tab(text: 'Message'),
    Tab(text: 'Friends'),
    Tab(text: 'Following'),
    Tab(text: 'Fans'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: myTabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // TabBar with padding & shift
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 8, 0),
              child: Transform.translate(
                offset: const Offset(-45, 0), // shift tab bar left
                child: Material(
                  color: Colors.transparent,
                  child: TabBar(
                    controller: _tabController,
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
                    tabs: myTabs,
                  ),
                ),
              ),
            ),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  MessageTab(),
                  FriendsTab(),
                  FollowingTab(),
                  FansTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}