import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';

class Validators {
  static final List<String> commonProviders = [
    'gmail.com',
    'googlemail.com',
    'yahoo.com',
    'yahoo.co.uk',
    'outlook.com',
    'hotmail.com',
    'icloud.com',
    'protonmail.com',
    'zoho.com',
    'msn.com',
    'aol.com',
  ];

  static final List<String> disposableDomains = [
    'mailinator.com',
    'temp-mail.org',
    '10minutemail.com',
    'guerrillamail.com',
    'yopmail.com',
    'trashmail.com',
    'fakeinbox.com',
    'maildrop.cc',
    'dispostable.com',
    'getnada.com',
  ];

  static bool isValidEmail(String email) {
    final regex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return regex.hasMatch(email.trim().toLowerCase());
  }

  static bool isAllowedEmailDomain(String email,
      {List<String> companyDomains = const []}) {
    if (!isValidEmail(email)) return false;
    final domain = email
        .trim()
        .toLowerCase()
        .split('@')
        .last;

    if (disposableDomains.contains(domain)) return false;
    if (commonProviders.contains(domain)) return true;
    if (companyDomains.contains(domain)) return true;

    return false;
  }

  /// ✅ Now static
  static String generateSalt() {
    final random = Random.secure();
    List<int> saltBytes =
    List.generate(16, (index) => random.nextInt(256));
    return base64Url.encode(saltBytes);
  }

  static String hashPassword(String password, String salt) {
    final bytes = utf8.encode("$password|$salt");
    final digest = sha256.convert(bytes);
    return "${base64Encode(digest.bytes)}|$salt";
  }

  static String? passwordValidator(String? value) {
    final bool passwordValid = RegExp(
        r"^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-.+=_]).{6,}$")
        .hasMatch(value!);
    if (passwordValid) {
      return null;
    }

    return "Password must be at least 6 characters, at least one uppercase, number, and special characters.";
  }

  static String? inviteCodeValidator(String? value) {
    if (value == null || value.trim().isEmpty) return null; // optional
    if (!RegExp(r'^[a-zA-Z0-9-]+$').hasMatch(value.trim())) {
      return "Invalid invitation code format";
    }
    if (value.trim().length < 4) return "Invitation code too short";
    if (value.trim().length > 12) return "Invitation code too long";
    return null;
  }
  static String? cfrmPassValidator(
      String? value,
      TextEditingController passwordController,
      TextEditingController confirmPasswordController) {
    final bool cfrmPasswordValid =
        passwordController.text == confirmPasswordController.text;
    if (cfrmPasswordValid) {
      return null;
    } else if (value!.isEmpty) {
      return 'Enter input.';
    } else {
      return "Password not match";
    }
  }
  static String generateRoomId({int length = 7}) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final rand = Random.secure();
    return List.generate(length, (index) => chars[rand.nextInt(chars.length)]).join();
  }
  /// SEA phone number validator
  static String? phoneValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    final cleaned = value.replaceAll(RegExp(r'[\s\-()]'), '');
    final regex = RegExp(r'^(?:\+?6?0?|62|65|66|84|63)?[2-9]\d{7,11}$');
    if (!regex.hasMatch(cleaned)) {
      return 'Enter a valid SEA phone number';
    }
    return null; // valid
  }
}