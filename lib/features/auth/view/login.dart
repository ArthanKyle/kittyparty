import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/global_widgets/buttons/login_button.dart';
import '../../../core/global_widgets/dialogs/dialog_info.dart';
import '../../../core/utils/validators.dart';
import '../viewmodel/login_viewmodel.dart';
import '../widgets/password_field.dart';
import '../widgets/text_field.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/utils/user_provider.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(),
      child: Consumer2<LoginViewModel, UserProvider>(
        builder: (context, vm, userProvider, child) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // Show error dialog if login failed
            if (vm.errorMessage != null) {
              DialogInfo(
                headerText: "Error",
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

            // 🚀 Navigate if user is logged in
            if (userProvider.isLoggedIn) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/',
                    (route) => false,
              );
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
                child: Form(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom,
                          ),
                          child: ConstrainedBox(
                            constraints:
                            BoxConstraints(minHeight: constraints.maxHeight),
                            child: IntrinsicHeight(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Spacer(),
                                  Image.asset(
                                    'assets/image/kitty-party-logo.jpg',
                                    height: 120,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Kitty Party',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.accentWhite,
                                    ),
                                  ),
                                  const SizedBox(height: 32),

                                  BasicTextField(
                                    controller: vm.emailController,
                                    labelText: 'Email',
                                    hintText: 'Enter email',
                                    validator: (val) =>
                                    Validators.isValidEmail(val ?? '')
                                        ? null
                                        : 'Invalid email',
                                  ),
                                  const SizedBox(height: 10),

                                  PasswordField(
                                    controller: vm.passwordController,
                                    labelText: 'Password',
                                    hintText: 'Enter password',
                                    validator: (p0) => Validators
                                        .passwordValidator(
                                        vm.passwordController.text),
                                  ),
                                  const SizedBox(height: 24),

                                  LoginButton(
                                    onPressed: vm.isLoading
                                        ? null
                                        : () => vm.login(context),
                                    text: 'Login',
                                    isDisabled: vm.isLoading,
                                  ),

                                  const SizedBox(height: 20),
                                  const Row(
                                    children: [
                                      Expanded(
                                          child: Divider(
                                              color: Colors.grey, thickness: 1)),
                                      SizedBox(width: 10),
                                      Text('or',
                                          style: TextStyle(
                                              color: AppColors.accentWhite)),
                                      SizedBox(width: 10),
                                      Expanded(
                                          child: Divider(
                                              color: Colors.grey, thickness: 1)),
                                    ],
                                  ),
                                  const SizedBox(height: 10),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/icons/google.svg',
                                        height: 25,
                                        width: 25,
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        "Don't have an account? ",
                                        style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          color: AppColors.accentWhite,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () => Navigator.pushNamed(
                                            context, '/registration'),
                                        child: const Text(
                                          'Sign up',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textLight,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
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
