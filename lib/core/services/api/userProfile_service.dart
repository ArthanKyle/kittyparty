import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../features/landing/model/userProfile.dart';

class UserProfileService {
  final String baseUrl;

  UserProfileService({String? baseUrl})
      : baseUrl = baseUrl ?? dotenv.env['BASE_URL']!;

  Future<UserProfile?> getProfileByUserId(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/userProfiles/$userId'));
    if (response.statusCode == 200) {
      return UserProfile.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<UserProfile?> uploadProfilePicture(String userId, File imageFile) async {
    final uri = Uri.parse('$baseUrl/userProfiles/$userId/profile-picture');
    final request = http.MultipartRequest('PUT', uri);

    request.files.add(await http.MultipartFile.fromPath(
      'ProfilePicture', // must match multer field
      imageFile.path,
    ));

    final response = await request.send();
    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      final data = jsonDecode(respStr);
      return UserProfile.fromJson(data['profile']);
    } else {
      throw Exception("Upload failed: ${response.statusCode}");
    }
  }

  Future<Uint8List?> fetchProfilePicture(String userId) async {
    final uri = Uri.parse('$baseUrl/userProfiles/$userId/profile-picture');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return response.bodyBytes;
    }
    return null;
  }
}
