import 'package:flutter/material.dart';
import 'core/config/app_theme.dart';
import 'bootstrap.dart';

// Auth
import 'core/config/global_keys.dart';
import 'features/auth/view/login.dart';
import 'features/auth/view/register.dart';
import 'features/auth/auth_module.dart';

// Navigation / Pages
import 'features/landing/view/landing_page.dart';
import 'features/landing/view/messages_page.dart';
import 'features/navigation/page_handler.dart';
import 'features/test.dart';
import 'features/wallet/view/wallet_page.dart';
import 'features/landing/view/post_page.dart';
import 'features/landing/view/profile_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kitty Party',
      navigatorKey: globalNavigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.auth,
      routes: {
        AppRoutes.home: (_) => const PageHandler(),
        AppRoutes.registration: (_) => const RegisterPage(),
        AppRoutes.landing: (_) => const LandingPage(),
        AppRoutes.auth: (_) => const AuthCheck(),
        AppRoutes.login: (_) => const Login(),
        AppRoutes.message: (_) => const MessagesPage(),
        AppRoutes.posts: (_) => const PostPage(),
        AppRoutes.profile: (_) => const ProfilePage(),
        AppRoutes.wallet: (_) => const WalletPage(),
        AppRoutes.test: (_) => const Next(),
      },
    );
  }
}

/// Centralized route names (prevents typos & eases refactor)
abstract class AppRoutes {
  static const home = "/";
  static const auth = "/auth";
  static const login = "/login";
  static const registration = "/registration";
  static const landing = "/landing";
  static const message = "/message";
  static const posts = "/posts";
  static const profile = "/profile";
  static const wallet = "/wallet";
  static const test = "/test";
}
