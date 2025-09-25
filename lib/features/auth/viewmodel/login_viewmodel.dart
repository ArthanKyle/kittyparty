import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/global_widgets/dialogs/dialog_loading.dart';
import '../../../core/services/api/auth_service.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/user_provider.dart';
import '../../auth/model/auth.dart';
import '../../auth/model/auth_response.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;
  bool loginSuccess = false;

  Future<void> login(BuildContext context) async {
    if (!_validateInputs()) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    DialogLoading(subtext: "Logging in....").build(context);

    try {
      print("🔑 Attempting login with email: ${emailController.text.trim()}");

      final response = await _authService.login(
        identifier: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      print("📩 Login API response: $response");

      if (response['error'] != null) {
        errorMessage = response['error'];
        print("❌ Login failed: $errorMessage");
      } else {
        // ✅ Save token + user in provider
        final authResponse = AuthResponse.fromJson(response);
        await Provider.of<UserProvider>(context, listen: false)
            .setUser(authResponse);

        print("✅ Login successful. Token saved: ${authResponse.token}");
        loginSuccess = true;
      }
    } catch (e) {
      errorMessage = e.toString();
      print("🔥 Exception during login: $e");
    } finally {
      isLoading = false;
      notifyListeners();

      Navigator.of(context, rootNavigator: true).pop();
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
