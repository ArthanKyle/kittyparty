import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/global_widgets/dialogs/dialog_info.dart';
import '../../../core/global_widgets/dialogs/dialog_loading.dart';
import '../../../core/services/api/auth_service.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/user_provider.dart';
import '../../auth/model/auth_response.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;
  bool loginSuccess = false;

  bool _googleInitDone = false;

  Future<void> _initGoogleOnce() async {
    if (_googleInitDone) return;

    final signIn = GoogleSignIn.instance;

    // v7: initialize WITHOUT 'scopes'
    await signIn.initialize(
      clientId: kIsWeb ? dotenv.env['GOOGLE_WEB_CLIENT_ID'] : null,
      serverClientId: kIsWeb ? null : dotenv.env['GOOGLE_WEB_CLIENT_ID'],
      // NOTE: scopes are handled later via authorization calls, not here.
    );

    // Optional: try a lightweight auth for returning users.
    unawaited(signIn.attemptLightweightAuthentication());

    _googleInitDone = true;
  }

  /// ------------------ GOOGLE SIGN-IN (v7) ------------------
  Future<void> handleGoogleLogin(BuildContext context) async {
    StreamSubscription? sub;
    try {
      isLoading = true;
      notifyListeners();

      await _initGoogleOnce();
      final signIn = GoogleSignIn.instance;

      // Wait for the next successful sign-in event.
      final completer = Completer<GoogleSignInAccount>();

      sub = signIn.authenticationEvents.listen((event) {
        if (event is GoogleSignInAuthenticationEventSignIn) {
          completer.complete(event.user); // <-- this gives you GoogleSignInAccount
        }
      }, onError: (err, st) {
        if (!completer.isCompleted) completer.completeError(err, st);
      });

      // Kick off UI-based auth where supported; otherwise your web UI should render the GSI button.
      if (signIn.supportsAuthenticate()) {
        await signIn.authenticate();
      }

      // Resolve to the signed-in account from the event stream.
      final account = await completer.future;

      // Get ID token (still available in v7).
      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) {
        throw Exception('Failed to retrieve Google ID token');
      }

      DialogLoading(subtext: "Authenticating...").build(context);

      final response = await _authService.googleLogin(idToken: idToken);

      Navigator.of(context, rootNavigator: true).pop(); // close loading

      if (response['status'] == 'not_registered' ||
          response['error'] == 'USER_NOT_FOUND') {
        Navigator.pushNamed(context, '/registration', arguments: {
          'email': account.email,
          'name': account.displayName ?? "Google User",
          'loginMethod': 'Google',
        });
        isLoading = false;
        notifyListeners();
        return;
      }

      final authResponse = AuthResponse.fromJson(response);
      await Provider.of<UserProvider>(context, listen: false)
          .setUser(authResponse);

      loginSuccess = true;
      Navigator.pushNamedAndRemoveUntil(context, "/", (route) => false);
    } catch (e, stack) {
      // Close any open loading dialog safely
      try {
        Navigator.of(context, rootNavigator: true).pop();
      } catch (_) {}

      errorMessage = e.toString();
      debugPrint("❌ Google Login Exception: $errorMessage");
      debugPrint("📜 Stack Trace: $stack");

      DialogInfo(
        headerText: "Google Sign-In Failed",
        subText: errorMessage!,
        confirmText: "OK",
        onConfirm: () => Navigator.of(context, rootNavigator: true).pop(),
        onCancel: () => Navigator.of(context, rootNavigator: true).pop(),
      ).build(context);
    } finally {
      await sub?.cancel();
      isLoading = false;
      notifyListeners();
    }
  }

  /// ------------------ EMAIL LOGIN ------------------
  Future<void> login(BuildContext context) async {
    if (!_validateInputs()) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    DialogLoading(subtext: "Logging in...").build(context);

    try {
      final response = await _authService.login(
        identifier: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (response['error'] != null) {
        errorMessage = response['error'];
        debugPrint("⚠️ Login error: ${response['error']}");
      } else {
        final authResponse = AuthResponse.fromJson(response);
        await Provider.of<UserProvider>(context, listen: false)
            .setUser(authResponse);
        loginSuccess = true;
        debugPrint("✅ Email login successful for ${authResponse.user.email}");
      }
    } catch (e, stack) {
      errorMessage = e.toString();
      debugPrint("❌ Email Login Exception: $errorMessage");
      debugPrint("📜 Stack Trace: $stack");
    } finally {
      isLoading = false;
      Navigator.of(context, rootNavigator: true).pop();
      notifyListeners();
    }
  }

  bool _validateInputs() {
    if (!Validators.isValidEmail(emailController.text.trim())) {
      errorMessage = "Invalid email format";
      notifyListeners();
      return false;
    }
    final passError =
        Validators.passwordValidator(passwordController.text.trim());
    if (passError != null) {
      errorMessage = passError;
      notifyListeners();
      return false;
    }
    return true;
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
