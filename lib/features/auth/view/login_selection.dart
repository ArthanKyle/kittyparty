import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/global_widgets/buttons/selection_button.dart';
import '../viewmodel/login_viewmodel.dart';

class LoginSelection extends StatelessWidget {
  const LoginSelection({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(),
      child: Consumer<LoginViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            backgroundColor: Colors.black,
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
                      // 🔸 Logo
                      Image.asset('assets/image/kitty-party-logo.jpg', height: 120),
                      const SizedBox(height: 16),

                      // 🔸 Title
                      const Text(
                        'Welcome to Kitty Party',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accentWhite,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),

                      // 🟣 Login with ID
                      SelectionButton(
                        text: "Login with ID",
                        isDisabled: vm.isLoading,
                        onPressed: () => Navigator.pushNamed(context, '/login/id'),
                      ),
                      const SizedBox(height: 16),

                      // 🟡 Login with Email
                      SelectionButton(
                        text: "Login with Email",
                        isDisabled: vm.isLoading,
                        onPressed: () => Navigator.pushNamed(context, '/login/email'),
                      ),
                      const SizedBox(height: 16),

                      // 🔵 Google Login (via ViewModel)
                      SelectionButton(
                        text: "Login with Google",
                        isDisabled: vm.isLoading,
                        onPressed: () async => await vm.handleGoogleLogin(context),
                      ),
                      const SizedBox(height: 32),

                      // 🔸 Register Link
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/registration'),
                        child: const Text(
                          "Don't have an account? Sign Up",
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
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
