import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'app.dart';
import 'core/services/api/socket_service.dart';
import 'core/services/api/user_service.dart';
import 'core/utils/locale_provider.dart';
import 'core/utils/user_provider.dart';
import 'core/utils/index_provider.dart';
import 'features/landing/viewmodel/post_viewmodel.dart';
import 'features/wallet/viewmodel/wallet_viewmodel.dart';
import 'features/wallet/viewmodel/diamond_viewmodel.dart';
import 'package:kittyparty/features/livestream/widgets/gift_auto_loader.dart';

late Box myRegBox;
late Box sessionsBox;

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await Hive.initFlutter();
  await GiftRegistry.load();

  final localeProvider = LocaleProvider();
  await localeProvider.loadSavedLocale();

  myRegBox = await Hive.openBox("myRegistrationBox");
  sessionsBox = await Hive.openBox("sessions");

  Stripe.publishableKey = dotenv.env["STRIPE_PUBLISHABLE_KEY"] ?? "";

  // Load user BEFORE building the widget tree
  final userProvider = UserProvider();
  await userProvider.loadUser();

  // Global socket instance used by other services/viewmodels
  final socketService = SocketService();
  if (userProvider.currentUser != null) {
    socketService.initSocket(userProvider.currentUser!.id);
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
        value: localeProvider,
        ),
        // Already-created userProvider instance
        ChangeNotifierProvider<UserProvider>.value(value: userProvider),

        ChangeNotifierProvider(create: (_) => PageIndexProvider()),

        // ⚡ PostViewModel is ALWAYS created, even if user is null at startup
        ChangeNotifierProvider(
          create: (_) => PostViewModel(
            currentUserId: userProvider.currentUser?.userIdentification ?? "",
            userProvider: userProvider,
          ),
        ),

        // Wallet & diamonds
        ChangeNotifierProvider(
          create: (_) => WalletViewModel(userProvider: userProvider),
        ),
        ChangeNotifierProvider(
          create: (_) => DiamondViewModel(
            userProvider: userProvider,
            socketService: socketService,
          ),
        ),

        // Plain services
        Provider(
          create: (_) => UserService(
            baseUrl: dotenv.env["BASE_URL"] ?? "",
          ),
        ),
        Provider<SocketService>.value(value: socketService),
      ],
      child: const MyApp(),
    ),
  );
}
