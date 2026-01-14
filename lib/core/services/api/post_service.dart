import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class PostService {
  final String baseUrl;

  PostService({String? baseUrl})
      : baseUrl = baseUrl ?? dotenv.env['BASE_URL']!;

  void _print(String lbl, http.Response res) {
    print("[$lbl] ${res.statusCode} → ${res.body}");
  }

  // ===========================================================
  // GET ALL POSTS
  // ===========================================================
  Future<List<dynamic>> getPosts(String userId) async {
    final url = Uri.parse('$baseUrl/posts?userId=$userId');
    final res = await http.get(url);

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    return [];
  }

  // ===========================================================
  // GET FOLLOWING POSTS
  // ===========================================================
  Future<List<dynamic>> getFollowingPosts(String userId) async {
    final url = Uri.parse('$baseUrl/posts/following/$userId');
    final res = await http.get(url);

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    return [];
  }

  // ===========================================================
  // DELETE POST
  // ===========================================================
    Future<bool> deletePost(String postId) async {
      final url = Uri.parse('$baseUrl/posts/$postId');

      final res = await http.delete(url);

      _print("DELETE /posts/$postId", res);

      return res.statusCode == 200;
    }


  // ===========================================================
  // CREATE POST (Images + Videos via GridFS)
  // ===========================================================
  Future<Map<String, dynamic>?> createPost({
    required Map<String, dynamic> body,
    List<File>? mediaFiles,
  }) async {
    final uri = Uri.parse("$baseUrl/posts");

    final request = http.MultipartRequest("POST", uri);

    // FIELDS
    body.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    // FILES (THIS IS WHERE YOU ADD IT)
    if (mediaFiles != null) {
      for (final file in mediaFiles) {

        print("UPLOAD SIZE = ${file.lengthSync()} bytes");

        final mimeType = lookupMimeType(file.path) ?? "image/jpeg";
        final parts = mimeType.split('/');

        request.files.add(
          await http.MultipartFile.fromPath(
            "media", // MUST match upload.array("media")
            file.path,
            contentType: MediaType(parts[0], parts[1]),
          ),
        );
      }
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    }

    return null;
  }

  // ===========================================================
  // ADD COMMENT
  // ===========================================================
  Future<bool> addComment({
    required String postId,
    required String userId,
    required String content,
  }) async {
    final url = Uri.parse('$baseUrl/posts/$postId/comments');

    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user": userId,
        "content": content,
      }),
    );

    _print("POST /posts/$postId/comments", res);

    return res.statusCode == 201;
  }

  // ===========================================================
  // GET COMMENTS
  // ===========================================================
  Future<List<dynamic>> getComments(String postId) async {
    final url = Uri.parse('$baseUrl/posts/$postId/comments');

    final res = await http.get(url);
    _print("GET /posts/$postId/comments", res);

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    return [];
  }

  // ===========================================================
  // LIKE POST
  // ===========================================================
  Future<bool> likePost(String postId, String userId) async {
    final url = Uri.parse('$baseUrl/posts/likes');

    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "postId": postId,
        "userId": userId,
      }),
    );

    _print("POST /posts/likes", res);

    return res.statusCode == 201;
  }

  // ===========================================================
  // UNLIKE POST
  // ===========================================================
  Future<bool> unlikePost(String postId, String userId) async {
    final url = Uri.parse('$baseUrl/posts/likes');

    final res = await http.delete(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "postId": postId,
        "userId": userId,
      }),
    );

    _print("DELETE /posts/likes", res);

    return res.statusCode == 200;
  }

  // ===========================================================
  // GET LIKES COUNT
  // ===========================================================
  Future<List<dynamic>> getLikes(String postId) async {
    final url = Uri.parse('$baseUrl/posts/$postId/likes');

    final res = await http.get(url);
    _print("GET /posts/$postId/likes", res);

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    return [];
  }

  // ===========================================================
  // CHECK IF USER LIKED
  // ===========================================================
  Future<bool> hasLiked(String postId, String userId) async {
    final url = Uri.parse('$baseUrl/posts/$postId/hasLiked/$userId');

    final res = await http.get(url);
    _print("GET /posts/$postId/hasLiked/$userId", res);

    if (res.statusCode == 200) {
      return jsonDecode(res.body)['liked'] == true;
    }
    return false;
  }
}
