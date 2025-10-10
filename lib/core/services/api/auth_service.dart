import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  final String baseUrl;

  AuthService({String? baseUrl})
      : baseUrl = baseUrl ?? dotenv.env['BASE_URL']!;

  /// 🧾 Register User + Auto-create Social Profile
  Future<Map<String, dynamic>> register({
    required String fullName,
    required String username,
    required String email,
    required String phoneNumber,
    required String countryCode,
    String loginMethod = "Email",
    String? invitationCode,
    bool isFirstTimeRecharge = true,
  }) async {
    final Map<String, dynamic> body = {
      "FullName": fullName,
      "Username": username,
      "Email": email,
      "PhoneNumber": phoneNumber,
      "CountryCode": countryCode,
      "LoginMethod": loginMethod,
      "isFirstTimeRecharge": isFirstTimeRecharge,
    };

    if (invitationCode != null && invitationCode.isNotEmpty) {
      body["InvitationCode"] = invitationCode;
    }

    final uri = Uri.parse('$baseUrl/auth/register');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    final data = _decodeResponse(response);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return data;
    } else {
      throw HttpException(data['message'] ?? 'Registration failed');
    }
  }

  /// 🔐 Email / ID Login
  Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
    String loginMethod = "Email",
  }) async {
    final uri = Uri.parse('$baseUrl/auth/login');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "identifier": identifier,
        "Password": password,
        "LoginMethod": loginMethod,
      }),
    );

    final data = _decodeResponse(response);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw HttpException(data['message'] ?? 'Login failed');
    }
  }

  /// 🔄 Auth Check (JWT validation)
  Future<Map<String, dynamic>> authCheck(String token) async {
    final uri = Uri.parse('$baseUrl/auth/authcheck');

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return _decodeResponse(response);
    } on SocketException {
      // Retry once (for Railway cold start)
      await Future.delayed(const Duration(seconds: 2));
      final retryResponse = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return _decodeResponse(retryResponse);
    }
  }

  /// 🔵 Google Sign-In → Backend Login
  Future<Map<String, dynamic>> googleLogin({
    required String idToken,
  }) async {
    final uri = Uri.parse('$baseUrl/auth/google-login');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"idToken": idToken}),
    );

    final data = _decodeResponse(response);
    print("🔹 Google Login Response: $data");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return data;
    } else {
      print("❌ Google Login Error: ${data['error'] ?? data['message']}");
      throw HttpException(data['error'] ?? data['message'] ?? 'Google login failed');
    }
  }

  /// 🚪 Logout (client-side clear)
  Future<Map<String, dynamic>> logout(String token) async {
    final uri = Uri.parse('$baseUrl/auth/logout');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = _decodeResponse(response);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw HttpException(data['message'] ?? 'Logout failed');
    }
  }

  /// 🧩 Private: Handle JSON decoding safely
  Map<String, dynamic> _decodeResponse(http.Response response) {
    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw HttpException('Invalid JSON response from server');
    }
  }
}
