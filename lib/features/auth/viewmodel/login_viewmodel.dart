import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/global_widgets/dialogs/dialog_info.dart';
import '../../../core/global_widgets/dialogs/dialog_loading.dart';
import '../../../core/services/api/auth_service.dart';
import '../../../core/utils/index_provider.dart';
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

  /// ------------------ GOOGLE SIGN-IN ------------------
  Future<void> handleGoogleLogin(BuildContext context) async {
    isLoading = true;
    notifyListeners();

    // Show the loading dialog and hold a reference to it
    DialogLoading(subtext: "Authenticating...").build(context);

    try {
      final googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        serverClientId: dotenv.env['GOOGLE_WEB_CLIENT_ID'],
      );

      final GoogleSignInAccount? account = await googleSignIn.signIn();
      if (account == null) throw Exception("Google sign-in was cancelled.");

      final GoogleSignInAuthentication auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) throw Exception("Failed to retrieve Google ID token.");

      final response = await _authService.googleLogin(idToken: idToken);

      // (The rest of your success logic here...)
      final authResponse = AuthResponse.fromJson(response);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.setUser(authResponse);

      Provider.of<PageIndexProvider>(context, listen: false).pageIndex = 0;
      loginSuccess = true;
      Navigator.pushNamedAndRemoveUntil(context, "/", (route) => false);

    } catch (e, stack) {
      errorMessage = e.toString();
      print("❌ Google Login Exception: $errorMessage");
      print("📜 Stack Trace: $stack");

      DialogInfo(
        headerText: "Google Sign-In Failed",
        subText: errorMessage!,
        confirmText: "OK",
        onConfirm: () => Navigator.of(context, rootNavigator: true).pop(),
        onCancel: ()  => Navigator.of(context, rootNavigator: true).pop(),
      ).build(context);

    } finally {
      // ✅ This block guarantees the loading dialog is always closed.
      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
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
        print("⚠️ Login error: ${response['error']}");
      } else {
        final authResponse = AuthResponse.fromJson(response);
        await Provider.of<UserProvider>(context, listen: false)
            .setUser(authResponse);

        // ✅ Reset page index to LandingPage (index 0)
        Provider.of<PageIndexProvider>(context, listen: false).pageIndex = 0;

        loginSuccess = true;
        print("✅ Email login successful for ${authResponse.user.email}");

        Navigator.pushNamedAndRemoveUntil(context, "/", (route) => false);
      }
    } catch (e, stack) {
      errorMessage = e.toString();
      print("❌ Email Login Exception: $errorMessage");
      print("📜 Stack Trace: $stack");
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
