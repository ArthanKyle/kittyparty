import 'package:flutter/material.dart';
import 'package:kittyparty/features/auth/view/login_selection.dart';
import 'package:kittyparty/features/livestream/view/live_audio_room.dart';
import 'package:kittyparty/features/profile/profile_pages/setting_page.dart';
import 'core/config/app_theme.dart';
import 'bootstrap.dart';

// Auth
import 'core/config/global_keys.dart';
import 'features/auth/view/email_login.dart';
import 'features/auth/view/id_login.dart';
import 'features/auth/view/register.dart';
import 'features/auth/auth_module.dart';

// Navigation / Pages
import 'features/landing/view/landing_page.dart';
import 'features/landing/view/messages_page.dart';
import 'features/navigation/page_handler.dart';
import 'features/test.dart';
import 'features/wallet/view/wallet_page.dart';
import 'features/landing/view/post_page.dart';
import 'features/profile/profile_page.dart';
import 'package:provider/provider.dart';
import 'core/utils/user_provider.dart';

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

      // ✅ Use onGenerateRoute for dynamic routes
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.home:
            return MaterialPageRoute(builder: (_) => const PageHandler());
          case AppRoutes.registration:
            return MaterialPageRoute(builder: (_) => const RegisterPage());
          case AppRoutes.landing:
            return MaterialPageRoute(builder: (_) => const LandingPage());
          case AppRoutes.auth:
            return MaterialPageRoute(builder: (_) => const AuthCheck());
          case AppRoutes.login:
            return MaterialPageRoute(builder: (_) => const LoginSelection());
          case AppRoutes.emailLogin:
            return MaterialPageRoute(builder: (_) => const EmailLogin());
          case AppRoutes.idLogin:
            return MaterialPageRoute(builder: (_) => const IdLogin());
          case AppRoutes.message:
            return MaterialPageRoute(builder: (_) => const MessagePage());
          case AppRoutes.posts:
            return MaterialPageRoute(builder: (_) => const PostPage());
          case AppRoutes.profile:
            return MaterialPageRoute(builder: (_) => const ProfilePage());
          case AppRoutes.wallet:
            return MaterialPageRoute(builder: (_) => const WalletPage());
          case AppRoutes.test:
            return MaterialPageRoute(builder: (_) => const Next());
          case AppRoutes.setting:
            return MaterialPageRoute(builder: (_) => const SettingPage());

        // ✅ Dynamic route for LiveAudioRoom
          case AppRoutes.room:
            final rawArgs = settings.arguments;
            final args = (rawArgs is Map)
                ? rawArgs.map((key, value) => MapEntry(key.toString(), value))
                : <String, dynamic>{};

            final userProvider = Provider.of<UserProvider>(
              globalNavigatorKey.currentContext!,
              listen: false,
            );

            return MaterialPageRoute(
              builder: (_) => LiveAudioRoom(
                roomId: args['roomId'] ?? '',
                hostId: args['hostId'] ?? '',
                roomName: args['roomName'] ?? 'Unnamed Room',
                userProvider: userProvider,
              ),
            );


          default:
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: Center(child: Text("Page not found")),
              ),
            );
        }
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
  static const room = "/room";
  static const setting = "/setting";
  static const emailLogin = "/login/email";
  static const idLogin = "/login/id";

}
