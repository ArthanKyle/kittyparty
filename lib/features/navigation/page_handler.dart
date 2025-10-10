import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kittyparty/features/landing/view/messages_page.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/global_widgets/buttons/route_button.dart';
import '../../core/utils/index_provider.dart';
import '../landing/view/landing_page.dart';
import '../landing/view/post_page.dart';
import '../profile/profile_page.dart';


class PageHandler extends StatefulWidget {
  const PageHandler({super.key});

  @override
  State<PageHandler> createState() => _PageHandlerState();
}

class _PageHandlerState extends State<PageHandler> {
  final pages = [
    const LandingPage(),
    const PostPage(),
    const MessagePage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    int pageIndex = Provider.of<PageIndexProvider>(context).pageIndex;

    return WillPopScope(
      onWillPop: () async {
        if (pageIndex == 0) SystemNavigator.pop();

        changePage(index: 0, context: context);

        return false;
      },
      child: Scaffold(
        body: IndexedStack(
          index: pageIndex,
          children: const <Widget>[
            LandingPage(),
            PostPage(),
            MessagePage(),
            ProfilePage(),
          ],
        ),
        backgroundColor: AppColors.accentWhite,
        bottomNavigationBar: SafeArea(
          child: SizedBox(
            height: 70, // enough space for buttons + safe area
            child: BottomAppBar(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FittedBox(
                  fit: BoxFit.scaleDown, // shrink content if needed
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RouteButton(
                        routeName: "Dashboard",
                        filePath: "assets/icons/home.svg",
                        routeCallback: () => changePage(index: 0, context: context),
                        currentIndex: pageIndex,
                        routeIndex: 0,
                      ),
                      const SizedBox(width: 16),
                      RouteButton(
                        routeName: "Posts",
                        filePath: "assets/icons/compass.svg",
                        routeCallback: () => changePage(index: 1, context: context),
                        currentIndex: pageIndex,
                        routeIndex: 1,
                      ),
                      const SizedBox(width: 16),
                      RouteButton(
                        routeName: "Messages",
                        filePath: "assets/icons/message.svg",
                        routeCallback: () => changePage(index: 2, context: context),
                        currentIndex: pageIndex,
                        routeIndex: 2,
                      ),
                      const SizedBox(width: 16),
                      RouteButton(
                        routeName: "Profile",
                        filePath: "assets/icons/profile.svg",
                        routeCallback: () => changePage(index: 3, context: context),
                        currentIndex: pageIndex,
                        routeIndex: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}