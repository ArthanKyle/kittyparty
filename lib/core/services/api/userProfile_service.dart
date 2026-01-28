import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../features/landing/model/userProfile.dart';

class UserProfileService {
  final String baseUrl;

  UserProfileService({String? baseUrl})
      : baseUrl = baseUrl ?? dotenv.env['BASE_URL']!;

  // =======================================
  // GET PROFILE (Metadata Only)
  // =======================================
  Future<UserProfile?> getProfileByUserIdentification(
      String userIdentification) async {
    final response = await http.get(
      Uri.parse('$baseUrl/userprofiles/$userIdentification'),
    );

    if (response.statusCode == 200) {
      return UserProfile.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  // =======================================
  // UPLOAD / UPDATE PROFILE PICTURE
  // =======================================
  Future<UserProfile?> uploadProfilePicture(String userIdentification,
      File imageFile) async {
    final uri = Uri.parse(
      '$baseUrl/userprofiles/$userIdentification/profile-picture',
    );

    final request = http.MultipartRequest('PUT', uri);

    request.files.add(
      await http.MultipartFile.fromPath(
        'ProfilePicture', // must match multer field name
        imageFile.path,
      ),
    );

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseString = await response.stream.bytesToString();
      final jsonData = jsonDecode(responseString);

      return UserProfile.fromJson(jsonData['profile']);
    } else {
      throw Exception("Upload failed with status: ${response.statusCode}");
    }
  }

  // =======================================
  // FETCH RAW PROFILE PICTURE FROM GRIDFS
  // =======================================
  Future<Uint8List?> fetchProfilePicture(String userIdentification) async {
    final response = await http.get(
      Uri.parse('$baseUrl/userprofiles/$userIdentification/profile-picture'),
    );

    if (response.statusCode == 200) {
      return response.bodyBytes;
    }

    return null;
  }

// =======================================
// UPDATE PROFILE (USERNAME + BIO + BIRTHDAY + ALBUM)
// =======================================
  Future<UpdateProfileResult> updateProfile({
    required String userIdentification, // PROFILE ID (46634)
    String? username,
    String? bio,
    String? birthday,
    List<String>? album,
  }) async {
    final uri = Uri.parse('$baseUrl/userprofiles/$userIdentification');

    debugPrint('[UserProfileService] PUT $uri');

    final response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        if (username != null) 'username': username,
        if (bio != null) 'bio': bio,
        if (birthday != null) 'birthday': birthday,
        if (album != null) 'album': album,
      }),
    );

    debugPrint(
      '[UserProfileService] status=${response.statusCode} body=${response
          .body}',
    );

    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);
      throw Exception(body['error'] ?? 'Failed to update profile');
    }

    final data = jsonDecode(response.body);

    return UpdateProfileResult(
      profile: UserProfile.fromJson(data['profile']),
      username: data['username'] as String?,
    );
  }
}

  class UpdateProfileResult {
  final UserProfile profile;
  final String? username;

  UpdateProfileResult({
    required this.profile,
    this.username,
  });
}

