import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
  String? googleIdToken;

  final formKey = GlobalKey<FormState>();

  // Controllers (NO PASSWORD)
  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController inviteController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  String selectedGender = "";
  String? selectedCountry;
  bool isFirstTimeRecharge = true;
  bool isLoading = false;

  RegisterViewModel() {
    _initListeners();
  }

  /* ================= LOCAL CACHE ================= */

  void _initListeners() {
    nameController.addListener(_saveFormData);
    usernameController.addListener(_saveFormData);
    emailController.addListener(_saveFormData);
    phoneController.addListener(_saveFormData);
    inviteController.addListener(_saveFormData);
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

  /* ================= SETTERS ================= */

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

  void setInitialValues({
    String? email,
    String? fullName,
    String? pictureUrl,
    String? idToken,
    bool isGoogleSignIn = false,
  }) {
    if (email != null) emailController.text = email;
    if (fullName != null) nameController.text = fullName;
    if (pictureUrl != null) this.pictureUrl = pictureUrl;

    googleIdToken = idToken;
    this.isGoogleSignIn = isGoogleSignIn;
    notifyListeners();
  }

  /* ================= REGISTER ================= */

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

      return response;
    } catch (e) {
      if (e is HttpException) return {"error": e.message};
      return {"error": e.toString()};
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /* ================= HANDLE REGISTER ================= */

  Future<void> handleRegister(BuildContext context) async {
    if (selectedGender.isEmpty) {
      _showError(context, "Please select your gender.");
      return;
    }

    if (selectedCountry == null) {
      _showError(context, "Please select your country.");
      return;
    }

    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    DialogLoading(subtext: "Creating account...").build(context);
    final response = await register();
    Navigator.of(context, rootNavigator: true).pop();

    if (response['error'] != null) {
      _showError(context, response['error']);
      return;
    }

    /* ================= AUTO LOGIN ================= */

    final authResponse = AuthResponse.fromJson(response);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.setUser(authResponse);

    Navigator.pushNamedAndRemoveUntil(context, "/", (_) => false);
  }

  /* ================= HELPERS ================= */

  void _showError(BuildContext context, String message) {
    DialogInfo(
      headerText: "Notice",
      subText: message,
      confirmText: "OK",
      onConfirm: () => Navigator.pop(context),
      onCancel: () => Navigator.pop(context),
    ).build(context);
  }

  @override
  void dispose() {
    nameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    inviteController.dispose();
    super.dispose();
  }
}
