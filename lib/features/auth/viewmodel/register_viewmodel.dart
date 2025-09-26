import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/global_widgets/dialogs/dialog_info.dart';
import '../../../core/global_widgets/dialogs/dialog_loading.dart';
import '../../../core/services/api/auth_service.dart';
import '../../../core/utils/validators.dart';
import 'login_viewmodel.dart';

class RegisterViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final myRegBox = Hive.box('myRegistrationBox');

  final formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController inviteController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  String selectedGender = "";
  String? selectedCountry;

  bool isLoading = false;
  bool isFirstTimeRecharge = true;

  RegisterViewModel() {
    _initListeners();
  }

  void _initListeners() {
    nameController.addListener(_saveFormData);
    usernameController.addListener(_saveFormData);
    emailController.addListener(_saveFormData);
    phoneController.addListener(_saveFormData);
    passwordController.addListener(_saveFormData);
    inviteController.addListener(_saveFormData);
    confirmPasswordController.addListener(_saveFormData);
  }

  void _saveFormData() {
    if (!myRegBox.isOpen) return;
    myRegBox.put('fullName', nameController.text.trim());
    myRegBox.put('username', usernameController.text.trim());
    myRegBox.put('email', emailController.text.trim());
    myRegBox.put('phoneNumber', phoneController.text.trim());
    myRegBox.put('password', passwordController.text.trim());
    myRegBox.put('inviteCode', inviteController.text.trim());
    myRegBox.put('gender', selectedGender);
    myRegBox.put('nationality', selectedCountry ?? '');
  }

  void setFirstTimeRecharge(bool value) {
    isFirstTimeRecharge = value;
    myRegBox.put('isFirstTimeRecharge', value);
    notifyListeners();
  }

  void setGender(String gender) {
    selectedGender = gender;
    _saveFormData();
    notifyListeners();
  }

  void setCountry(String? country) {
    selectedCountry = country;
    myRegBox.put('nationality', country ?? '');
    notifyListeners();
  }

  Future<Map<String, dynamic>> register() async {
    if (!formKey.currentState!.validate()) {
      return {"error": "Form is not valid"};
    }

    isLoading = true;
    notifyListeners();

    try {
      final response = await _authService.register(
        fullName: nameController.text.trim(),
        username: usernameController.text.trim(),
        email: emailController.text.trim(),
        phoneNumber: phoneController.text.trim(),
        password: passwordController.text.trim(),
        countryCode: selectedCountry ?? '',
        invitationCode: inviteController.text.trim().isEmpty ? null : inviteController.text.trim(),
        isFirstTimeRecharge: isFirstTimeRecharge,
      );

      return response;
    } catch (e) {
      return {"error": e.toString()};
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> handleRegister(BuildContext context) async {
    // Check gender
    if (selectedGender.isEmpty) {
      DialogInfo(
        headerText: "Missing Info",
        subText: "Please select your gender.",
        confirmText: "OK",
        onConfirm: () => Navigator.of(context, rootNavigator: true).pop(),
        onCancel: () =>  Navigator.of(context, rootNavigator: true).pop(),
      ).build(context);
      return;
    }

    // Check country
    if (selectedCountry == null) {
      DialogInfo(
        headerText: "Missing Info",
        subText: "Please select your country.",
        confirmText: "OK",
        onConfirm: () => Navigator.of(context, rootNavigator: true).pop(),
        onCancel: () =>  Navigator.of(context, rootNavigator: true).pop(),
      ).build(context);
      return;
    }

    // Validate form
    if (!(formKey.currentState?.validate() ?? false)) {
      formKey.currentState?.validate(); // show errors
      return;
    }

    // Show loading
    DialogLoading(subtext: "Creating...").build(context);

    final response = await register();

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

          final loginVM = LoginViewModel();
          loginVM.emailController.text = emailController.text.trim();
          loginVM.passwordController.text = passwordController.text.trim();

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
  }


  @override
  void dispose() {
    nameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    inviteController.dispose();
    super.dispose();
  }
}
