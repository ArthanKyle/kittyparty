import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

class PostService {
  final String baseUrl;

  PostService({String? baseUrl})
      : baseUrl = baseUrl ?? dotenv.env['BASE_URL']!;

  // Debug helper
  void _print(String lbl, http.Response res) {
    print("[$lbl] ${res.statusCode} → ${res.body}");
  }

  // ---------------- GET ALL POSTS ----------------
  Future<List<dynamic>> getPosts() async {
    final url = Uri.parse('$baseUrl/posts');
    final res = await http.get(url);
    _print("GET /posts", res);

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    return [];
  }

  // ---------------- GET FOLLOWING POSTS ----------------
  Future<List<dynamic>> getFollowingPosts(String userId) async {
    final url = Uri.parse('$baseUrl/posts/following/$userId');
    final res = await http.get(url);
    _print("GET /posts/following/$userId", res);

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    return [];
  }

  // ---------------- CREATE POST ----------------
  Future<Map<String, dynamic>?> createPost({
    required Map<String, dynamic> body,
    List<File>? mediaFiles,
  }) async {
    final url = Uri.parse('$baseUrl/posts');

    // ----- SIMPLE POST WITHOUT MEDIA -----
    if (mediaFiles == null || mediaFiles.isEmpty) {
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      _print("POST /posts", res);

      if (res.statusCode == 201) {
        return jsonDecode(res.body);
      }
      return null;
    }

    // ----- MULTIPART POST WITH MEDIA -----
    final request = http.MultipartRequest('POST', url);

    // Add fields
    body.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    // Add files
    for (var file in mediaFiles) {
      request.files.add(await http.MultipartFile.fromPath(
        'media',
        file.path,
        filename: p.basename(file.path),
      ));
    }

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    _print("POST /posts (multipart)", res);

    if (res.statusCode == 201) {
      return jsonDecode(res.body);
    }
    return null;
  }
}
