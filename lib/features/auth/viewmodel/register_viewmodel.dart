import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/global_widgets/dialogs/dialog_info.dart';
import '../../../core/global_widgets/dialogs/dialog_loading.dart';
import '../../../core/services/api/auth_service.dart';
import 'dart:io';

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

  void setInitialValues({String? email, String? fullName}) {
    if (email != null && emailController.text.isEmpty) {
      emailController.text = email;
    }
    if (fullName != null && nameController.text.isEmpty) {
      nameController.text = fullName;
    }
    _saveFormData(); // save to Hive if needed
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
      );

      print("📥 Register response: $response");

      // ✅ Always return the data, even if status code is 201
      return response;
    } catch (e) {
      // If the exception is HttpException, extract message properly
      if (e is HttpException) {
        return {"error": e.message};
      }
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
        onCancel: () => Navigator.of(context, rootNavigator: true).pop(),
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
        onCancel: () => Navigator.of(context, rootNavigator: true).pop(),
      ).build(context);
      return;
    }

    // Validate form
    if (!(formKey.currentState?.validate() ?? false)) {
      formKey.currentState?.validate();
      return;
    }

    // Show loading dialog
    DialogLoading(subtext: "Creating account...").build(context);

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
        subText:
        "Your account has been created successfully.",
        confirmText: "Go to home.",
        onConfirm: () {
          Navigator.of(context, rootNavigator: true).pop();
          Navigator.pushNamedAndRemoveUntil(context, "/", (_) => false);
        },
        onCancel: () {
          Navigator.of(context, rootNavigator: true).pop();
          Navigator.pushNamedAndRemoveUntil(context, "/login", (_) => false);
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
    inviteController.dispose();
    super.dispose();
  }
}
