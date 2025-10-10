import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/global_widgets/buttons/login_button.dart';
import '../../../core/global_widgets/dialogs/dialog_info.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/user_provider.dart';
import '../viewmodel/login_viewmodel.dart';
import '../widgets/arrow_back.dart';
import '../widgets/password_field.dart';
import '../widgets/text_field.dart';

class IdLogin extends StatelessWidget {
  const IdLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(),
      child: Consumer2<LoginViewModel, UserProvider>(
        builder: (context, vm, userProvider, child) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (vm.errorMessage != null) {
              DialogInfo(
                headerText: "Login Failed",
                subText: vm.errorMessage!,
                confirmText: "Try again",
                onConfirm: () {
                  Navigator.of(context, rootNavigator: true).pop();
                  vm.errorMessage = null;
                },
                onCancel: () {
                  Navigator.of(context, rootNavigator: true).pop();
                  vm.errorMessage = null;
                },
              ).build(context);
            }

            if (userProvider.isLoggedIn) {
              Navigator.pushNamedAndRemoveUntil(context, "/", (route) => false);
            }
          });
          return Scaffold(
            resizeToAvoidBottomInset: true,
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: AppColors.mainGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ArrowBack(onTap: () => Navigator.pop(context)),
                      Image.asset('assets/image/kitty-party-logo.jpg', height: 120),
                      const SizedBox(height: 16),
                      const Text(
                        'Login with ID',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accentWhite,
                        ),
                      ),
                      const SizedBox(height: 32),

                      BasicTextField(
                        controller: vm.emailController,
                        labelText: 'User ID',
                        hintText: 'Enter your ID',
                        validator: (val) =>
                        val != null && val.trim().isNotEmpty ? null : 'ID required',
                      ),
                      const SizedBox(height: 12),

                      PasswordField(
                        controller: vm.passwordController,
                        labelText: 'Password',
                        hintText: 'Enter password',
                        validator: (val) =>
                            Validators.passwordValidator(vm.passwordController.text),
                      ),
                      const SizedBox(height: 24),

                      LoginButton(
                        onPressed: vm.isLoading ? null : () => vm.login(context),
                        text: 'Login',
                        isDisabled: vm.isLoading,
                      ),
                      const SizedBox(height: 24),

                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
