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
import 'features/livestream/widgets/gift_assets.dart';
import 'features/wallet/viewmodel/wallet_viewmodel.dart';
import 'features/wallet/viewmodel/diamond_viewmodel.dart';

late Box myRegBox;
late Box sessionsBox;

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await Hive.initFlutter();
  await GiftAssets.load();

  final localeProvider = LocaleProvider();
  await localeProvider.loadSavedLocale();

  myRegBox = await Hive.openBox("myRegistrationBox");
  sessionsBox = await Hive.openBox("sessions");

  Stripe.publishableKey = dotenv.env["STRIPE_PUBLISHABLE_KEY"] ?? "";

  // Load user BEFORE building widget tree
  final userProvider = UserProvider();
  await userProvider.loadUser();

  // Global socket
  final socketService = SocketService();
  if (userProvider.currentUser != null) {
    socketService.initSocket(userProvider.currentUser!.userIdentification);
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: localeProvider),

        // User Provider
        ChangeNotifierProvider<UserProvider>.value(value: userProvider),

        // Page index
        ChangeNotifierProvider(create: (_) => PageIndexProvider()),

        // NEW PostViewModel (no currentUserId parameter)
        ChangeNotifierProvider(
          create: (_) => PostViewModel(userProvider: userProvider),
        ),

        // Wallet & Diamonds
        ChangeNotifierProvider(
          create: (_) => WalletViewModel(userProvider: userProvider),
        ),
        ChangeNotifierProvider(
          create: (_) => DiamondViewModel(
            userProvider: userProvider,
            socketService: socketService,
          ),
        ),

        // Services
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
