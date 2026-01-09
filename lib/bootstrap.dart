import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'app.dart';

// Services
import 'core/services/api/agency_service.dart';
import 'core/services/api/conversion_recharge.dart';
import 'core/services/api/dailyTask_service.dart';
import 'core/services/api/socket_service.dart';
import 'core/services/api/user_service.dart';
import 'core/services/api/wallet_service.dart';


// Providers
import 'core/services/api/wealth_service.dart';
import 'core/utils/locale_provider.dart';
import 'core/utils/user_provider.dart';
import 'core/utils/index_provider.dart';

// ViewModels
import 'features/landing/viewmodel/agency_viewmodel.dart';
import 'features/landing/viewmodel/dailyTask_viewmodel.dart';
import 'features/landing/viewmodel/landing_viewmodel.dart';
import 'features/landing/viewmodel/mall_viewmodel.dart';
import 'features/landing/viewmodel/post_viewmodel.dart';
import 'features/landing/viewmodel/profile_viewmodel.dart';
import 'features/landing/viewmodel/wealth_viewmodel.dart';
import 'features/wallet/viewmodel/wallet_viewmodel.dart';

// Assets
import 'features/livestream/widgets/gift_assets.dart';

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



  // 🔑 Load user BEFORE widget tree
  final userProvider = UserProvider();
  await userProvider.loadUser();

  final socketService = SocketService();
  if (userProvider.currentUser != null) {
    socketService.initSocket(userProvider.currentUser!.id);
  }

  runApp(
    MultiProvider(
      providers: [
        // Locale
        ChangeNotifierProvider.value(value: localeProvider),

        //Profile
        ChangeNotifierProvider(
          create: (context) => ProfileViewModel()..loadProfile(context),
        ),

        // Auth / User
        ChangeNotifierProvider<UserProvider>.value(value: userProvider),

        // Navigation
        ChangeNotifierProvider(create: (_) => PageIndexProvider()),

        // Landing
        ChangeNotifierProvider(create: (_) => LandingViewModel()),

        // Posts
        ChangeNotifierProvider(
          create: (_) => PostViewModel(userProvider: userProvider),
        ),

        ChangeNotifierProvider(
          create: (_) => WealthViewModel(
            service: WealthService(),
          ),
        ),
        ChangeNotifierProvider<AgencyViewModel>(
            create: (_) => AgencyViewModel(
              service: AgencyService(), // ✅ uses dotenv.env['BASE_URL']
            ),
        ),

        ChangeNotifierProvider(create: (_) => MallViewModel()),

        // ✅ WALLET (single source of truth)
        ChangeNotifierProvider(
          create: (_) => WalletViewModel(
            userProvider: userProvider,
            walletService: WalletService(),
            conversionService: ConversionService(),
            socketService: socketService,
          ),
        ),

        // Daily Tasks
        ChangeNotifierProvider(
          create: (_) => DailyTaskViewModel(
            DailyTaskService(),
          ),
        ),

        // API Services
        Provider(
          create: (_) => UserService(
            baseUrl: dotenv.env["BASE_URL"] ?? "",
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
