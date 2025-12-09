import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ProfilePictureHelper {
  static Future<List<dynamic>> fetchAllProfilePictures() async {
    final baseUrl = dotenv.env['BASE_URL'] ?? "";
    final url = Uri.parse("$baseUrl/api/profile/pictures");

    final resp = await http.get(url);

    if (resp.statusCode != 200) {
      return [];
    }

    return jsonDecode(resp.body);
  }

  static String buildAvatarUrl(String base, String userId) {
    return "$base/api/profile/picture/$userId";
  }
}
