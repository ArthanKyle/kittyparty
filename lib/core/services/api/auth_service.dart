import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  final String baseUrl;

  AuthService({String? baseUrl})
      : baseUrl = baseUrl ?? dotenv.env['BASE_URL']!;

  Future<Map<String, dynamic>> register({
    required String fullName,
    required String username,
    required String email,
    required String phoneNumber,
    required String password,
    required String countryCode,
    String loginMethod = "Email",
    String? invitationCode,
    required bool isFirstTimeRecharge,
  }) async {
    final body = {
      "FullName": fullName,
      "Username": username,
      "Email": email,
      "PhoneNumber": phoneNumber,
      "Password": password,
      "LoginMethod": loginMethod,
      "CountryCode": countryCode,
      "IsFirstTimeRecharge": isFirstTimeRecharge, // <-- added
    };
    if (invitationCode != null && invitationCode.isNotEmpty) {
      body["InvitationCode"] = invitationCode;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
    String loginMethod = "Email",
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "identifier": identifier,
        "Password": password,
        "LoginMethod": loginMethod,
      }),
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> authCheck(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/authcheck'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    return jsonDecode(response.body);
  }

  /// 🔑 Logout API (stateless, just clears session client-side)
  Future<Map<String, dynamic>> logout(String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/logout'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    return jsonDecode(response.body);
  }
}
