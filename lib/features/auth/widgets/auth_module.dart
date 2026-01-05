import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/index_provider.dart';
import '../../../core/utils/user_provider.dart';
import '../../navigation/page_handler.dart';
import '../view/login_selection.dart';

class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  bool _didResetIndex = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<UserProvider>().loadUser();
    });
  }

  void _resetPageIndexOnce() {
    if (_didResetIndex) return;
    _didResetIndex = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<PageIndexProvider>().reset();
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
      // ✅ schedule reset safely (NOT during build)
      _resetPageIndexOnce();
      return const PageHandler();
    }

    // if not logged in, allow future reset when user logs in again
    _didResetIndex = false;
    return const LoginSelection();
  }
}
