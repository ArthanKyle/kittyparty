import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/global_widgets/dialogs/dialog_info.dart';
import '../../../../core/global_widgets/dialogs/dialog_loading.dart';
import '../../../../core/services/api/auth_service.dart';
import '../../../../core/utils/user_provider.dart';
import '../../../../core/utils/validators.dart';

class SetPasswordPage extends StatefulWidget {
  const SetPasswordPage({Key? key}) : super(key: key);

  @override
  State<SetPasswordPage> createState() => _SetPasswordPageState();
}

class _SetPasswordPageState extends State<SetPasswordPage> {
  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool isLoading = false;
  String? errorMessage;

  Future<void> _setPassword(BuildContext context) async {
    final newPass = _newPassController.text.trim();
    final confirmPass = _confirmPassController.text.trim();

    // --- Input Validation ---
    final passwordError = Validators.passwordValidator(newPass);
    if (passwordError != null) {
      _showMessage(passwordError);
      return;
    }

    final confirmError = Validators.cfrmPassValidator(
      confirmPass,
      _newPassController,
      _confirmPassController,
    );
    if (confirmError != null) {
      _showMessage(confirmError);
      return;
    }

    final token = Provider.of<UserProvider>(context, listen: false).token;
    if (token == null) {
      _showMessage("Session expired. Please log in again.");
      return;
    }

    // --- Show Loading ---
    isLoading = true;
    errorMessage = null;
    setState(() {});
    DialogLoading(subtext: "Setting password...").build(context);

    try {
      final response =
      await _authService.setPassword(token: token, password: newPass);

      Navigator.of(context, rootNavigator: true).pop();

      if (response['error'] != null) {
        errorMessage = response['error'];
        print("⚠️ Set Password Error: ${response['error']}");
        _showMessage(errorMessage!);
      } else {
        print("✅ Password set successfully");

        DialogInfo(
          headerText: "Success",
          subText: "Your password has been set successfully!",
          confirmText: "OK",
          onCancel: () {},
          onConfirm: () {
            Navigator.of(context, rootNavigator: true).pop();
            Navigator.pop(context);
          },
        ).build(context);
      }
    } catch (e, stack) {
      errorMessage = e.toString();
      print("❌ Set Password Exception: $errorMessage");
      print("📜 Stack Trace: $stack");

      Navigator.of(context, rootNavigator: true).pop();
      _showMessage("Something went wrong while setting your password.");
    } finally {
      isLoading = false;
      setState(() {});
    }
  }

  void _showMessage(String msg) {
    DialogInfo(
      headerText: "Notice",
      subText: msg,
      confirmText: "OK",
      onCancel: () {},
      onConfirm: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    ).build(context);
  }

  @override
  Widget build(BuildContext context) {
    final isButtonActive = _newPassController.text.isNotEmpty &&
        _confirmPassController.text.isNotEmpty &&
        !isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Set Password",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildPasswordField(
              controller: _newPassController,
              hintText: "Enter new password",
              obscure: _obscureNew,
              toggle: () => setState(() => _obscureNew = !_obscureNew),
            ),
            const SizedBox(height: 16),
            _buildPasswordField(
              controller: _confirmPassController,
              hintText: "Confirm new password",
              obscure: _obscureConfirm,
              toggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
            ),
            const SizedBox(height: 10),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Must be 8–16 characters, include uppercase, number, and special character.",
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: isButtonActive ? () => _setPassword(context) : null,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  gradient: LinearGradient(
                    colors: isButtonActive
                        ? [AppColors.primaryLight, AppColors.primary]
                        : [Colors.grey.shade300, Colors.grey.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Text(
                    isLoading ? "Processing..." : "Submit",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool obscure,
    required VoidCallback toggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF4F8F5),
        borderRadius: BorderRadius.circular(40),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: TextInputType.visiblePassword,
        textAlignVertical: TextAlignVertical.center,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          border: InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          suffixIcon: IconButton(
            icon: Icon(
              obscure
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: Colors.grey,
            ),
            onPressed: toggle,
          ),
        ),
      ),
    );
  }
}
