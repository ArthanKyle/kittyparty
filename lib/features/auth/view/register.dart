import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/global_widgets/buttons/gradient_button.dart';
import '../../../core/global_widgets/gradient_background/gradient_background.dart';
import '../../../core/utils/validators.dart';
import '../viewmodel/register_viewmodel.dart';
import '../widgets/arrow_back.dart';
import '../widgets/country_dropdown.dart';
import '../widgets/gender_options.dart';
import '../widgets/password_field.dart';
import '../widgets/text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _prefilled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_prefilled) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

      if (args != null) {
        final email = args['email'] as String?;
        final name = args['name'] as String?;

        final registerVM = Provider.of<RegisterViewModel>(context, listen: false);
        registerVM.setInitialValues(email: email, fullName: name);
      }

      _prefilled = true; // ensure we only prefill once
    }
  }

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
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r"[a-zA-ZÀ-ÿ\s\-]"))
                              ],
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
                            BasicTextField(
                              labelText: 'Invitational Code',
                              controller: vm.inviteController,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) return null;
                                return Validators.inviteCodeValidator(value);
                              },
                              hintText: "Please enter invitation code (Optional)",
                            ),
                            CountryDropdown(
                              selectedCountry: vm.selectedCountry,
                              onChanged: vm.setCountry,
                            ),

                            GradientButton(
                              text: "Register account",
                              onPressed: () => vm.handleRegister(context),
                            ),
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
