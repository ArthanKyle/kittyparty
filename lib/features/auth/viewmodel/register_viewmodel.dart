import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import '../../../core/global_widgets/dialogs/dialog_info.dart';
import '../../../core/global_widgets/dialogs/dialog_loading.dart';
import '../../../core/services/api/auth_service.dart';
import '../../../core/utils/user_provider.dart';
import '../../auth/model/auth_response.dart';

class RegisterViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final myRegBox = Hive.box('myRegistrationBox');
  bool isGoogleSignIn = false;
  String? pictureUrl;

  final formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController inviteController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

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
    inviteController.addListener(_saveFormData);
    passwordController.addListener(_saveFormData);
  }

  void _saveFormData() {
    if (!myRegBox.isOpen) return;
    myRegBox.put('fullName', nameController.text.trim());
    myRegBox.put('username', usernameController.text.trim());
    myRegBox.put('email', emailController.text.trim());
    myRegBox.put('phoneNumber', phoneController.text.trim());
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

  void setInitialValues({
    String? email,
    String? fullName,
    String? pictureUrl,
    bool isGoogleSignIn = false,
  }) {
    if (email != null) emailController.text = email;
    if (fullName != null) nameController.text = fullName;
    if (pictureUrl != null) this.pictureUrl = pictureUrl;
    this.isGoogleSignIn = isGoogleSignIn;
    notifyListeners();
  }

  void setCountry(String? country) {
    selectedCountry = country;
    myRegBox.put('nationality', country ?? '');
    notifyListeners();
  }

  Future<Map<String, dynamic>> register() async {
    if (!formKey.currentState!.validate()) {
      print("⚠️ Form validation failed");
      return {"error": "Form is not valid"};
    }

    isLoading = true;
    notifyListeners();

    try {
      final bodyData = {
        "FullName": nameController.text.trim(),
        "Username": usernameController.text.trim(),
        "Email": emailController.text.trim(),
        "PhoneNumber": phoneController.text.trim(),
        "CountryCode": selectedCountry ?? '',
        "Gender": selectedGender,
        "InvitationCode": inviteController.text.trim().isEmpty
            ? null
            : inviteController.text.trim(),
        "isFirstTimeRecharge": isFirstTimeRecharge,
        "Password": passwordController.text.trim(),
      };

      print("📤 Registering user with data: $bodyData");

      final response = await _authService.register(
        fullName: nameController.text.trim(),
        username: usernameController.text.trim(),
        email: emailController.text.trim(),
        phoneNumber: phoneController.text.trim(),
        countryCode: selectedCountry ?? '',
        gender: selectedGender,
        invitationCode: inviteController.text.trim().isEmpty
            ? null
            : inviteController.text.trim(),
        isFirstTimeRecharge: isFirstTimeRecharge,
        loginMethod: isGoogleSignIn ? "Google" : "Email",
      );

      if (response['MyInvitationCode'] != null) {
        myRegBox.put('myInvitationCode', response['MyInvitationCode']);
      }

      print("📥 Register response: $response");

      return response;
    } catch (e) {
      if (e is HttpException) return {"error": e.message};
      return {"error": e.toString()};
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> handleRegister(BuildContext context) async {
    if (selectedGender.isEmpty) {
      DialogInfo(
        headerText: "Missing Info",
        subText: "Please select your gender.",
        confirmText: "OK",
        onConfirm: () => Navigator.of(context, rootNavigator: true).pop(),
        onCancel: () => Navigator.of(context, rootNavigator: true).pop(),
      ).build(context);
      return;
    }

    if (selectedCountry == null) {
      DialogInfo(
        headerText: "Missing Info",
        subText: "Please select your country.",
        confirmText: "OK",
        onConfirm: () => Navigator.of(context, rootNavigator: true).pop(),
        onCancel: () => Navigator.of(context, rootNavigator: true).pop(),
      ).build(context);
      return;
    }

    if (!(formKey.currentState?.validate() ?? false)) {
      formKey.currentState?.validate();
      return;
    }

    DialogLoading(subtext: "Creating account...").build(context);
    final response = await register();
    Navigator.of(context, rootNavigator: true).pop();

    if (response['error'] != null) {
      DialogInfo(
        headerText: "Error",
        subText: response['error'],
        confirmText: "Try again",
        onConfirm: () => Navigator.of(context, rootNavigator: true).pop(),
        onCancel: () => Navigator.of(context, rootNavigator: true).pop(),
      ).build(context);
      return;
    }

    // ✅ Handle Google registration (login immediately)
    if (isGoogleSignIn) {
      try {
        DialogLoading(subtext: "Finishing Google Sign-In...").build(context);

        // 👇 Call backend Google login again to fetch token + user info
        final googleLoginResponse = await _authService.googleLogin(
          idToken: response['idToken'] ?? '', // Pass the same idToken if stored
        );

        Navigator.of(context, rootNavigator: true).pop(); // close loading

        if (googleLoginResponse['status'] == 'success') {
          final authResponse = AuthResponse.fromJson(googleLoginResponse);
          final userProvider = Provider.of<UserProvider>(context, listen: false);
          await userProvider.setUser(authResponse);

          DialogInfo(
            headerText: "Welcome!",
            subText: "Your Google account has been linked successfully.",
            confirmText: "Continue",
            onConfirm: () {
              Navigator.of(context, rootNavigator: true).pop();
              Navigator.pushNamedAndRemoveUntil(context, "/", (_) => false);
            },
            onCancel: () => Navigator.of(context, rootNavigator: true).pop(),
          ).build(context);
        } else {
          throw Exception("Google login failed after registration.");
        }
      } catch (e) {
        Navigator.of(context, rootNavigator: true).pop();
        DialogInfo(
          headerText: "Linked, but not logged in",
          subText:
          "Your Google account has been registered, but auto-login failed. Please log in manually.",
          confirmText: "OK",
          onConfirm: () {
            Navigator.of(context, rootNavigator: true).pop();
            Navigator.pushNamedAndRemoveUntil(context, "/login", (_) => false);
          },
          onCancel: () => Navigator.of(context, rootNavigator: true).pop(),
        ).build(context);
      }
      return;
    }

    // ✅ Auto-login for normal registration
    try {
      DialogLoading(subtext: "Logging in...").build(context);

      final loginResponse = await _authService.login(
        identifier: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      Navigator.of(context, rootNavigator: true).pop(); // close loading dialog

      final authResponse = AuthResponse.fromJson(loginResponse);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.setUser(authResponse);

      DialogInfo(
        headerText: "Welcome!",
        subText: "Your account has been created and you’re now logged in.",
        confirmText: "Continue",
        onConfirm: () {
          Navigator.of(context, rootNavigator: true).pop();
          Navigator.pushNamedAndRemoveUntil(context, "/", (_) => false);
        },
        onCancel: () => Navigator.of(context, rootNavigator: true).pop(),
      ).build(context);
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      DialogInfo(
        headerText: "Account Created",
        subText:
        "Registration succeeded, but automatic login failed. Please log in manually.",
        confirmText: "Go to Login",
        onConfirm: () {
          Navigator.of(context, rootNavigator: true).pop();
          Navigator.pushNamedAndRemoveUntil(context, "/login", (_) => false);
        },
        onCancel: () => Navigator.of(context, rootNavigator: true).pop(),
      ).build(context);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    inviteController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
