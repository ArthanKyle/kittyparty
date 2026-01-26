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

  // ================= PHONE RULES =================

  static const Map<String, int> _phoneMaxDigits = {
    "PH": 11,
    "PK": 10,
    "BR": 11,
    "IN": 10,
    "MY": 9,
    "BD": 10,
    "ID": 11,
    "NP": 10,
    "RU": 10,
    "GR": 10,
    "US": 10,
    "CO": 10,
    "ET": 9,
  };

  static int maxLength(String? countryCode) {
    return _phoneMaxDigits[countryCode] ?? 12;
  }

  /// Country-aware phone validator
  static String? validate(String? value, String? countryCode) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    final expectedLength = maxLength(countryCode);

    if (digitsOnly.length != expectedLength) {
      return 'Phone number must be $expectedLength digits';
    }

    return null;
  }

  // ================= EMAIL =================

  static bool isValidEmail(String email) {
    final regex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return regex.hasMatch(email.trim().toLowerCase());
  }

  static bool isAllowedEmailDomain(
      String email, {
        List<String> companyDomains = const [],
      }) {
    if (!isValidEmail(email)) return false;
    final domain = email.trim().toLowerCase().split('@').last;

    if (disposableDomains.contains(domain)) return false;
    if (commonProviders.contains(domain)) return true;
    if (companyDomains.contains(domain)) return true;

    return false;
  }

  // ================= PASSWORD =================

  static String generateSalt() {
    final random = Random.secure();
    final saltBytes = List.generate(16, (_) => random.nextInt(256));
    return base64Url.encode(saltBytes);
  }

  static String hashPassword(String password, String salt) {
    final bytes = utf8.encode("$password|$salt");
    final digest = sha256.convert(bytes);
    return "${base64Encode(digest.bytes)}|$salt";
  }

  static String? passwordValidator(String? value) {
    final valid = RegExp(
      r"^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-.+=_]).{6,}$",
    ).hasMatch(value ?? '');

    if (valid) return null;

    return "Password must be at least 6 characters, at least one uppercase, number, and special characters.";
  }

  // ================= INVITE =================

  static String? inviteCodeValidator(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (!RegExp(r'^[a-zA-Z0-9-]+$').hasMatch(value.trim())) {
      return "Invalid invitation code format";
    }
    if (value.trim().length < 4) return "Invitation code too short";
    if (value.trim().length > 12) return "Invitation code too long";
    return null;
  }

  // ================= CONFIRM PASSWORD =================

  static String? cfrmPassValidator(
      String? value,
      TextEditingController passwordController,
      TextEditingController confirmPasswordController,
      ) {
    if (value == null || value.isEmpty) return 'Enter input.';
    if (passwordController.text != confirmPasswordController.text) {
      return "Password not match";
    }
    return null;
  }

  // ================= UTIL =================

  static String generateRoomId({int length = 7}) {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final rand = Random.secure();
    return List.generate(
      length,
          (_) => chars[rand.nextInt(chars.length)],
    ).join();
  }
}
