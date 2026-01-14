import 'package:flutter/material.dart';
import 'package:kittyparty/features/auth/view/login_selection.dart';
import 'package:kittyparty/features/livestream/view/live_audio_room.dart';
import 'package:kittyparty/features/profile/profile_pages/agency/create_agency.dart';
import 'package:kittyparty/features/profile/profile_pages/agency_room.dart';
import 'package:kittyparty/features/profile/profile_pages/daily_task_page.dart';
import 'package:kittyparty/features/profile/profile_pages/invite_page.dart';
import 'package:kittyparty/features/profile/profile_pages/setting_page.dart';
import 'package:kittyparty/features/svga_tester.dart';
import 'package:kittyparty/features/wallet/view/convert_coins_to_diamond_page.dart';
import 'package:kittyparty/features/wallet/view/monthly_recharge_page.dart';
import 'core/config/app_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/utils/locale_provider.dart';
// Auth
import 'core/config/global_keys.dart';
import 'features/auth/view/email_login.dart';
import 'features/auth/view/id_login.dart';
import 'features/auth/view/register.dart';
import 'features/auth/widgets/auth_module.dart';
// Navigation / Pages
import 'features/auth/viewmodel/register_viewmodel.dart';
import 'features/landing/view/landing_page.dart';
import 'features/landing/view/messages_page.dart';
import 'features/navigation/page_handler.dart';
import 'features/profile/profile_pages/transaction_page.dart';
import 'features/profile/profile_pages/vip_page.dart';
import 'features/test.dart';
import 'features/wallet/view/wallet_page.dart';
import 'features/landing/view/post_page.dart';
import 'features/profile/profile_page.dart';
import 'core/utils/user_provider.dart';
//profile
import 'package:kittyparty/features/profile/profile_pages/collection_page.dart';
import 'package:kittyparty/features/profile/profile_pages/item_page.dart';
import 'package:kittyparty/features/profile/profile_pages/level_page.dart';
import 'package:kittyparty/features/profile/profile_pages/mall_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      title: 'Kitty Party',
      navigatorKey: globalNavigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: localeProvider.locale,

      supportedLocales: const [
        Locale('en'),
        Locale('zh'),
        Locale('ar'),
        Locale('tr'),
        Locale('pt'),
        Locale('ru'),
        Locale('es'),
        Locale('uz'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      initialRoute: AppRoutes.auth,

      // ✅ Use onGenerateRoute for dynamic routes
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.home:
            return MaterialPageRoute(builder: (_) => const PageHandler());
          case AppRoutes.registration:
            final args = settings.arguments as Map<String, dynamic>?;

            return MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider(
                create: (_) => RegisterViewModel()
                  ..setInitialValues(
                    email: args?['email'],
                    fullName: args?['name'],
                    pictureUrl: args?['picture'],
                    isGoogleSignIn: true,
                  ),
                child: const RegisterPage(),
              ),
            );
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
          case AppRoutes.agency:
            return MaterialPageRoute(builder: (_) => const AgencyRoom());
          case AppRoutes.wallet:
            return MaterialPageRoute(builder: (_) => const WalletPage());
          case AppRoutes.test:
            return MaterialPageRoute(builder: (_) => AssetTest());
          case AppRoutes.testSVGA:
            return MaterialPageRoute(builder: (_) => const SvgATesterPage());
          case AppRoutes.setting:
            return MaterialPageRoute(builder: (_) => const SettingPage());
          case AppRoutes.diamond:
            return MaterialPageRoute(builder: (_) => const ConvertCoinsPage());

          // ✅ Profile subpages
          case AppRoutes.vip:
            return MaterialPageRoute(builder: (_) => const VipPage());
          case AppRoutes.collection:
            return MaterialPageRoute(builder: (_) => const CollectionPage());
          case AppRoutes.item:
            return MaterialPageRoute(builder: (_) => const ItemPage());
          case AppRoutes.level:
            return MaterialPageRoute(builder: (_) => const LevelPage());
          case AppRoutes.mall:
            return MaterialPageRoute(builder: (_) => const MallPage());
          case AppRoutes.invite:
            return MaterialPageRoute(builder: (_) => const InvitePage());
          case AppRoutes.tasks:
            return MaterialPageRoute(builder: (_) => const DailyTaskPage());
          case AppRoutes.monthlyRecharge:
            return MaterialPageRoute(
              builder: (_) => const MonthlyRechargePage(),
            );

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
              builder: (_) =>
                  const Scaffold(body: Center(child: Text("Coming soon!"))),
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
  static const collection = "/profile/collection";
  static const item = "/profile/item";
  static const level = "/profile/level";
  static const mall = "/profile/mall";
  static const invite = "/profile/invite";
  static const tasks = "/profile/tasks";
  static const monthlyRecharge = "/profile/monthly-recharge";
  static const testSVGA = "/test/svga";
  static const vip = "/profile/vip";
  static const agency = "/agency";
  static const diamond = "/recharge/convert";
  static const transactions = "/profile/transactions";
}
