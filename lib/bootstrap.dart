import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'app.dart';
import 'core/services/api/socket_service.dart';
import 'core/services/api/user_service.dart';
import 'core/utils/user_provider.dart';
import 'core/utils/index_provider.dart';
import 'features/landing/viewmodel/post_viewmodel.dart';
import 'features/wallet/viewmodel/wallet_viewmodel.dart';
import 'features/wallet/viewmodel/diamond_viewmodel.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

late Box myRegBox;
late Box sessionsBox;

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await Hive.initFlutter();
  myRegBox = await Hive.openBox("myRegistrationBox");
  sessionsBox = await Hive.openBox("sessions");

  Stripe.publishableKey = dotenv.env["STRIPE_PUBLISHABLE_KEY"] ?? "";

  // Load user
  final userProvider = UserProvider();
  await userProvider.loadUser();

  // Initialize socket
  final socketService = SocketService();
  if (userProvider.currentUser != null) {
    socketService.initSocket(userProvider.currentUser!.id);
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => userProvider),
        ChangeNotifierProvider(create: (_) => PageIndexProvider()),

        // ✅ PostViewModel with correct user ID
        if (userProvider.currentUser != null)
          ChangeNotifierProvider(
            create: (_) =>
                PostViewModel(currentUserId: userProvider.currentUser!.id),
          ),

        ChangeNotifierProvider(
          create: (_) => WalletViewModel(userProvider: userProvider),
        ),
        ChangeNotifierProvider(
          create: (_) => DiamondViewModel(
            userProvider: userProvider,
            socketService: socketService,
          ),
        ),

        Provider(create: (_) => UserService(baseUrl: dotenv.env["BASE_URL"] ?? "")),
        Provider(create: (_) => socketService),
      ],
      child: const MyApp(),
    ),
  );
}
