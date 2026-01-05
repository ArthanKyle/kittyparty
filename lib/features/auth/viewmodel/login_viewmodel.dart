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
  final idController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;
  bool loginSuccess = false;

  Future<void> handleGoogleLogin(BuildContext context) async {
    isLoading = true;
    notifyListeners();

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

      Navigator.of(context, rootNavigator: true).pop(); // close loading

      if (response['status'] == 'not_registered') {
        Navigator.pushNamed(
          context,
          '/registration',
          arguments: {
            'email': response['email'],
            'name': response['name'],
            'picture': response['picture'],
            'idToken': idToken,
            'isGoogleSignIn': true,
          },
        );
      } else if (response['status'] == 'success') {
        final authResponse = AuthResponse.fromJson(response);
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.setUser(authResponse);

        context.read<PageIndexProvider>().reset();
        loginSuccess = true;
        Navigator.pushNamedAndRemoveUntil(context, "/", (route) => false);
      }
    } catch (e, stack) {
      errorMessage = e.toString();
      print("❌ Google Login Exception: $errorMessage\n📜 $stack");

      if (Navigator.of(context).canPop()) Navigator.of(context).pop();

      DialogInfo(
        headerText: "Google Sign-In Failed",
        subText: errorMessage!,
        confirmText: "OK",
        onConfirm: () => Navigator.of(context, rootNavigator: true).pop(),
        onCancel: () => Navigator.of(context, rootNavigator: true).pop(),
      ).build(context);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }


  Future<void> loginWithID(BuildContext context) async {
    if (!_validateIDLogin()) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    DialogLoading(subtext: "Logging in with ID...").build(context);

    try {
      final response = await _authService.IDlogin(
        identifier: idController.text.trim(),
        password: passwordController.text.trim(),
      );

      Navigator.of(context, rootNavigator: true).pop();

      if (response['error'] != null) {
        errorMessage = response['error'];
        print("⚠️ Login error: ${response['error']}");
        _showErrorDialog(context, "Login Failed", errorMessage!);
      } else {
        final authResponse = AuthResponse.fromJson(response);
        await Provider.of<UserProvider>(context, listen: false)
            .setUser(authResponse);

        context.read<PageIndexProvider>().reset();

        loginSuccess = true;
        print("✅ ID login successful for ${authResponse.user.userIdentification}");

        Navigator.pushNamedAndRemoveUntil(context, "/", (route) => false);
      }
    } catch (e, stack) {
      errorMessage = e.toString();
      print("❌ ID Login Exception: $errorMessage\n📜 $stack");

      if (Navigator.of(context).canPop()) Navigator.of(context).pop();
      _showErrorDialog(context, "Login Failed", "Something went wrong.");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(BuildContext context) async {
    if (!_validateEmailLogin()) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    DialogLoading(subtext: "Logging in...").build(context);

    try {
      final response = await _authService.login(
        identifier: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      Navigator.of(context, rootNavigator: true).pop();

      if (response['error'] != null) {
        errorMessage = response['error'];
        print("⚠️ Login error: ${response['error']}");
        _showErrorDialog(context, "Login Failed", errorMessage!);
      } else {
        final authResponse = AuthResponse.fromJson(response);
        await Provider.of<UserProvider>(context, listen: false)
            .setUser(authResponse);

        context.read<PageIndexProvider>().reset();

        loginSuccess = true;
        print("✅ Email login successful for ${authResponse.user.email}");

        Navigator.pushNamedAndRemoveUntil(context, "/", (route) => false);
      }
    } catch (e, stack) {
      errorMessage = e.toString();
      print("❌ Email Login Exception: $errorMessage\n📜 $stack");

      if (Navigator.of(context).canPop()) Navigator.of(context).pop();
      _showErrorDialog(context, "Login Failed", "Something went wrong.");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  bool _validateEmailLogin() {
    if (!Validators.isValidEmail(emailController.text.trim())) {
      errorMessage = "Invalid email format";
      notifyListeners();
      return false;
    }

    final passError = Validators.passwordValidator(passwordController.text.trim());
    if (passError != null) {
      errorMessage = passError;
      notifyListeners();
      return false;
    }
    return true;
  }

  bool _validateIDLogin() {
    if (idController.text.trim().isEmpty) {
      errorMessage = "User ID is required";
      notifyListeners();
      return false;
    }

    final passError = Validators.passwordValidator(passwordController.text.trim());
    if (passError != null) {
      errorMessage = passError;
      notifyListeners();
      return false;
    }
    return true;
  }

  void _showErrorDialog(BuildContext context, String header, String message) {
    DialogInfo(
      headerText: header,
      subText: message,
      confirmText: "OK",
      onConfirm: () => Navigator.of(context, rootNavigator: true).pop(),
      onCancel: () => Navigator.of(context, rootNavigator: true).pop(),
    ).build(context);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    idController.dispose();
    super.dispose();
  }
}
