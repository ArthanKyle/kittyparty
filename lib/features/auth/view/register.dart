import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/global_widgets/buttons/gradient_button.dart';
import '../../../core/global_widgets/dialogs/dialog_info.dart';
import '../../../core/global_widgets/dialogs/dialog_loading.dart';
import '../../../core/global_widgets/gradient_background/gradient_background.dart';
import '../../../core/utils/validators.dart';
import '../viewmodel/login_viewmodel.dart';
import '../viewmodel/register_viewmodel.dart';
import '../widgets/arrow_back.dart';
import '../widgets/country_dropdown.dart';
import '../widgets/gender_options.dart';
import '../widgets/password_field.dart';
import '../widgets/text_field.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegisterViewModel(),
      child: Consumer<RegisterViewModel>(
        builder: (context, vm, child) {
          return GradientBackground(
            child: Scaffold(
              resizeToAvoidBottomInset: true,
              backgroundColor: Colors.transparent,
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: Form(
                        key: vm.formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ArrowBack(onTap: () => Navigator.pop(context)),
                            const SizedBox(height: 8),
                            const Text("Complete information", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.accentWhite)),
                            const SizedBox(height: 20),

                            // Gender
                            const Text("Please select your gender", style: TextStyle(fontSize: 14, color: AppColors.accentWhite)),
                            const SizedBox(height: 4),
                            const Text("(Gender cannot be modified later~)", style: TextStyle(fontSize: 10, color: AppColors.accentWhite)),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GenderOption(
                                  label: "Boy",
                                  icon: Icons.male,
                                  value: "boy",
                                  selectedGender: vm.selectedGender,
                                  onTap: () => vm.setGender("boy"),
                                ),
                                const SizedBox(width: 20),
                                GenderOption(
                                  label: "Girl",
                                  icon: Icons.female,
                                  value: "girl",
                                  selectedGender: vm.selectedGender,
                                  onTap: () => vm.setGender("girl"),
                                ),
                              ],
                            ),

                            const SizedBox(height: 28),
                            BasicTextField(
                              labelText: 'Name',
                              controller: vm.nameController,
                              hintText: 'Please enter your Full Name.',
                              validator: (value) => value == null || value.trim().isEmpty ? "Name is required" : null,
                            ),
                            BasicTextField(
                              labelText: 'UserName',
                              controller: vm.usernameController,
                              hintText: 'Please enter your User Name.',
                              validator: (value) => value == null || value.trim().isEmpty ? "UserName is required" : null,
                            ),
                            BasicTextField(
                              labelText: 'Email',
                              hintText: 'Please enter your email.',
                              controller: vm.emailController,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) return 'Enter your email.';
                                if (!Validators.isValidEmail(value)) return 'Enter a valid email address.';
                                if (!Validators.isAllowedEmailDomain(value, companyDomains: ['mycompany.com'])) return 'Email domain is not allowed.';
                                return null;
                              },
                            ),
                            BasicTextField(
                              labelText: 'Phone Number',
                              hintText: 'Please enter your phone number.',
                              controller: vm.phoneController,
                              validator: Validators.phoneValidator,
                              inputType: TextInputType.phone,
                            ),
                            PasswordField(
                              labelText: 'Password',
                              controller: vm.passwordController,
                              hintText: 'Password must be at least 8 characters, at least one uppercase, number, and special characters.',
                              validator: Validators.passwordValidator,
                            ),
                            PasswordField(
                              labelText: 'Confirm Password',
                              controller: vm.confirmPasswordController,
                              hintText: 'Password must match.',
                              validator: (value) => Validators.cfrmPassValidator(value, vm.passwordController, vm.confirmPasswordController),
                            ),
                            BasicTextField(
                              labelText: 'Invitational Code',
                              controller: vm.inviteController,
                              validator: Validators.inviteCodeValidator,
                              hintText: "Please enter invitation code (Optional)",
                            ),

                            CountryDropdown(
                              selectedCountry: vm.selectedCountry,
                              onChanged: vm.setCountry,
                            ),

                            GradientButton(
                              text: "Register account",
                              onPressed: () async {
                                DialogLoading(subtext: "Creating...").build(context);

                                final response = await vm.register();

                                Navigator.of(context, rootNavigator: true).pop(); // close loading

                                if (response['error'] != null) {
                                  DialogInfo(
                                    headerText: "Error",
                                    subText: response['error'],
                                    confirmText: "Try again",
                                    onCancel: () => Navigator.of(context, rootNavigator: true).pop(),
                                    onConfirm: () => Navigator.of(context, rootNavigator: true).pop(),
                                  ).build(context);
                                } else {
                                  DialogInfo(
                                    headerText: "Success",
                                    subText: "You have created an account! Logging in...",
                                    confirmText: "OK",
                                    onCancel: () => Navigator.of(context, rootNavigator: true).pop(),
                                    onConfirm: () async {
                                      Navigator.of(context, rootNavigator: true).pop();

                                      // Use LoginViewModel for login
                                      final loginVM = LoginViewModel();
                                      loginVM.emailController.text = vm.emailController.text.trim();
                                      loginVM.passwordController.text = vm.passwordController.text.trim();

                                      await loginVM.login(context);

                                      if (loginVM.loginSuccess) {
                                        Navigator.pushNamedAndRemoveUntil(context, "/", (route) => false);
                                      } else {
                                        DialogInfo(
                                          headerText: "Login Failed",
                                          subText: loginVM.errorMessage ?? "Something went wrong.",
                                          confirmText: "OK",
                                          onConfirm: () =>
                                              Navigator.of(context, rootNavigator: true).pop(),
                                          onCancel: () =>
                                              Navigator.of(context, rootNavigator: true).pop(),
                                        ).build(context);

                                        Navigator.pushNamed(context, "/login");
                                      }
                                    },

                                  ).build(context);
                                }
                              },
                            )
                          ],
                        ),
                      ),
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
