import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'app.dart';

// ================= SERVICES =================
import 'core/config/global_keys.dart';
import 'core/services/api/agency_service.dart';
import 'core/services/api/conversion_recharge.dart';
import 'core/services/api/dailyTask_service.dart';
import 'core/services/api/gift_transaction_service.dart';
import 'core/services/api/recharge_service.dart';
import 'core/services/api/room_income_service.dart';
import 'core/services/api/socket_service.dart';
import 'core/services/api/user_service.dart';
import 'core/services/api/wallet_service.dart';
import 'core/services/api/wealth_service.dart';

// ================= PROVIDERS =================
import 'core/utils/locale_provider.dart';
import 'core/utils/user_provider.dart';
import 'core/utils/index_provider.dart';

// ================= VIEWMODELS =================
import 'features/landing/viewmodel/agency_viewmodel.dart';
import 'features/landing/viewmodel/dailyTask_viewmodel.dart';
import 'features/landing/viewmodel/event_ranking_viewmodel.dart';
import 'features/landing/viewmodel/inventory_viewmodel.dart';
import 'features/landing/viewmodel/landing_viewmodel.dart';
import 'features/landing/viewmodel/mall_viewmodel.dart';
import 'features/landing/viewmodel/post_viewmodel.dart';
import 'features/landing/viewmodel/profile_viewmodel.dart';
import 'features/landing/viewmodel/transaction_viewmodel.dart';
import 'features/landing/viewmodel/wealth_viewmodel.dart';
import 'features/wallet/viewmodel/wallet_viewmodel.dart';

// ================= ASSETS =================
import 'features/livestream/widgets/gift_assets.dart';

late Box myRegBox;
late Box sessionsBox;

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ================= ENV & STORAGE =================
  await dotenv.load(fileName: ".env");
  await Hive.initFlutter();
  await GiftAssets.load();

  myRegBox = await Hive.openBox("myRegistrationBox");
  sessionsBox = await Hive.openBox("sessions");

  // ================= LOCALE =================
  final localeProvider = LocaleProvider();
  await localeProvider.loadSavedLocale();

  // ================= STRIPE =================
  Stripe.publishableKey =
      dotenv.env["STRIPE_PUBLISHABLE_KEY"] ?? "";

  // ================= USER =================
  final userProvider = UserProvider();
  await userProvider.loadUser();

  // ================= SOCKET =================
  final socketService = SocketService();
  if (userProvider.currentUser != null) {
    socketService.initSocket(userProvider.currentUser!.id);
  }

  // ================= RUN APP =================
  runApp(
    MultiProvider(
      providers: [
        // -------- SERVICES --------
        Provider(create: (_) => GiftTransactionService()),
        Provider(create: (_) => RechargeService()),
        Provider(create: (_) => RoomIncomeService()),
        Provider(create: (_) => UserService(
          baseUrl: dotenv.env["BASE_URL"] ?? "",
        )),

        // -------- CORE --------
        ChangeNotifierProvider.value(value: localeProvider),
        ChangeNotifierProvider<UserProvider>.value(value: userProvider),
        ChangeNotifierProvider(create: (_) => PageIndexProvider()),

        // -------- VIEWMODELS --------
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        ChangeNotifierProvider(create: (_) => LandingViewModel()),
        ChangeNotifierProvider(
          create: (_) => PostViewModel(userProvider: userProvider),
        ),
        ChangeNotifierProvider(create: (_) => ItemViewModel()),
        ChangeNotifierProvider(
          create: (_) => WealthViewModel(service: WealthService()),
        ),
        ChangeNotifierProvider(
          create: (_) => AgencyViewModel(
            service: AgencyService(),
          ),
        ),
        ChangeNotifierProvider(create: (_) => EventRankingViewModel()),
        ChangeNotifierProvider(create: (_) => MallViewModel()),
        ChangeNotifierProvider(
          create: (context) => TransactionViewModel(
            giftService: context.read<GiftTransactionService>(),
            rechargeService: context.read<RechargeService>(),
            roomIncomeService: context.read<RoomIncomeService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => WalletViewModel(
            userProvider: context.read<UserProvider>(),
            walletService: WalletService(),
            conversionService: ConversionService(),
            socketService: SocketService(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => DailyTaskViewModel(
            DailyTaskService(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
  // ================= PRELOAD AGENCY =================
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final user = userProvider.currentUser;
    if (user == null) return;

    final ctx = globalNavigatorKey.currentContext;
    if (ctx == null) return;

    ctx.read<AgencyViewModel>().loadMyAgency(
      user.userIdentification,
    );
  });
}