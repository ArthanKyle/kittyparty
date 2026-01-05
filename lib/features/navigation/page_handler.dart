import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kittyparty/features/landing/view/messages_page.dart';
import 'package:provider/provider.dart';

import '../../core/constants/colors.dart';
import '../../core/global_widgets/buttons/route_button.dart';
import '../../core/utils/index_provider.dart';
import '../../core/utils/user_provider.dart';
import '../landing/view/landing_page.dart';
import '../landing/view/post_page.dart';
import '../profile/profile_page.dart';
import '../landing/viewmodel/landing_viewmodel.dart';

class PageHandler extends StatefulWidget {
  const PageHandler({super.key});

  @override
  State<PageHandler> createState() => _PageHandlerState();
}

class _PageHandlerState extends State<PageHandler> {
  int _lastIndex = -1;
  bool _refreshScheduled = false;

  void _scheduleDashboardRefresh() {
    if (_refreshScheduled) return;
    _refreshScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshScheduled = false;
      if (!mounted) return;

      final landingVM = context.read<LandingViewModel>();
      final userProvider = context.read<UserProvider>();
      landingVM.refreshMyRooms(userProvider);
    });
  }

  void _handleIndexChanged(int newIndex) {
    if (newIndex == _lastIndex) return;
    _lastIndex = newIndex;

    if (newIndex == 0) {
      _scheduleDashboardRefresh();
    }
  }

  void _goTo(int index) {
    if (!mounted) return;
    context.read<PageIndexProvider>().setPage(index);
  }

  @override
  Widget build(BuildContext context) {
    final pageIndex = context.watch<PageIndexProvider>().pageIndex;

    // React safely to tab changes
    _handleIndexChanged(pageIndex);

    return WillPopScope(
      onWillPop: () async {
        if (pageIndex == 0) {
          SystemNavigator.pop();
          return false;
        }

        _goTo(0);
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.accentWhite,
        body: IndexedStack(
          index: pageIndex,
          children: const <Widget>[
            LandingPage(),
            PostPage(),
            MessagePage(),
            ProfilePage(),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: SizedBox(
            height: 70,
            child: BottomAppBar(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RouteButton(
                        routeName: "Dashboard",
                        filePath: "assets/icons/home.svg",
                        routeCallback: () => _goTo(0),
                        currentIndex: pageIndex,
                        routeIndex: 0,
                      ),
                      const SizedBox(width: 16),
                      RouteButton(
                        routeName: "Posts",
                        filePath: "assets/icons/compass.svg",
                        routeCallback: () => _goTo(1),
                        currentIndex: pageIndex,
                        routeIndex: 1,
                      ),
                      const SizedBox(width: 16),
                      RouteButton(
                        routeName: "Messages",
                        filePath: "assets/icons/message.svg",
                        routeCallback: () => _goTo(2),
                        currentIndex: pageIndex,
                        routeIndex: 2,
                      ),
                      const SizedBox(width: 16),
                      RouteButton(
                        routeName: "Profile",
                        filePath: "assets/icons/profile.svg",
                        routeCallback: () => _goTo(3),
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
