import 'package:flutter/material.dart';
import 'package:kittyparty/features/auth/view/login_selection.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/index_provider.dart';
import '../../../core/utils/user_provider.dart';
import '../../navigation/page_handler.dart';


class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).loadUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    if (userProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (userProvider.isLoggedIn) {
      // ✅ Reset page index to LandingPage
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<PageIndexProvider>(context, listen: false).pageIndex = 0;
      });

      return const PageHandler();
    } else {
      return const LoginSelection();
    }
  }
}
