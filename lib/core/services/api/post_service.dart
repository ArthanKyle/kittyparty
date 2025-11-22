import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

class PostService {
  final String baseUrl;

  PostService({String? baseUrl})
      : baseUrl = baseUrl ?? dotenv.env['BASE_URL']!;

  // ---------------- Helper ----------------
  void _printRawResponse(String tag, http.Response res, {bool pretty = true}) {
    print("[$tag] Status: ${res.statusCode}");
    try {
      final decoded = jsonDecode(res.body);
      print(
          "[$tag] Body: ${pretty ? JsonEncoder.withIndent('  ').convert(decoded) : res.body}");
    } catch (_) {
      print("[$tag] Body (raw): ${res.body}");
    }
  }

  // ---------------- Posts ----------------
  Future<List<dynamic>> getPosts({int page = 1, int limit = 20}) async {
    try {
      final url = Uri.parse('$baseUrl/posts?page=$page&limit=$limit');
      final res = await http.get(url);
      _printRawResponse("GET /posts", res);

      if (res.statusCode == 200) {
        return jsonDecode(res.body) as List<dynamic>;
      }
    } catch (e) {
      print("[PostService] Error fetching posts: $e");
    }
    return [];
  }

  Future<Map<String, dynamic>?> getPost(String id) async {
    try {
      final url = Uri.parse('$baseUrl/posts/$id');
      final res = await http.get(url);
      _printRawResponse("GET /posts/$id", res);

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      print("[PostService] Error fetching post: $e");
    }
    return null;
  }

  Future<Map<String, dynamic>?> createPost({
    required Map<String, dynamic> body,
    List<File>? mediaFiles,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/posts');

      if (mediaFiles == null || mediaFiles.isEmpty) {
        final res = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        );
        _printRawResponse("POST /posts", res);

        if (res.statusCode == 200 || res.statusCode == 201) {
          return jsonDecode(res.body);
        }
        return null;
      }

      final request = http.MultipartRequest('POST', url);
      body.forEach((key, value) => request.fields[key] = value.toString());
      for (var file in mediaFiles) {
        final fileName = p.basename(file.path);
        request.files.add(await http.MultipartFile.fromPath('media', file.path, filename: fileName));
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      _printRawResponse("POST /posts (multipart)", response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("[PostService] Error creating post: $e");
    }
    return null;
  }

  Future<Map<String, dynamic>?> addMedia(String postId, File file) async {
    try {
      final url = Uri.parse('$baseUrl/posts/$postId/media');
      final request = http.MultipartRequest('POST', url);
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      _printRawResponse("POST /posts/$postId/media", response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("[PostService] Error adding media: $e");
    }
    return null;
  }

  // ---------------- Comments ----------------
  Future<List<dynamic>> getComments(String postId) async {
    try {
      final url = Uri.parse('$baseUrl/posts/$postId/comments');
      final res = await http.get(url);
      _printRawResponse("GET /posts/$postId/comments", res);

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      print("[PostService] Error fetching comments: $e");
    }
    return [];
  }

  Future<Map<String, dynamic>?> addComment(String postId, Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('$baseUrl/posts/$postId/comments');
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      _printRawResponse("POST /posts/$postId/comments", res);

      if (res.statusCode == 200 || res.statusCode == 201) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      print("[PostService] Error adding comment: $e");
    }
    return null;
  }

  // ---------------- Likes ----------------
  Future<bool> addLike(Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('$baseUrl/posts/likes');
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      _printRawResponse("POST /posts/likes", res);

      return res.statusCode == 200 || res.statusCode == 201;
    } catch (e) {
      print("[PostService] Error adding like: $e");
      return false;
    }
  }

  Future<bool> removeLike(Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('$baseUrl/posts/likes');
      final req = http.Request('DELETE', url)
        ..headers['Content-Type'] = 'application/json'
        ..body = jsonEncode(data);

      final streamed = await req.send();
      final response = await http.Response.fromStream(streamed);
      _printRawResponse("DELETE /posts/likes", response);

      return response.statusCode == 200;
    } catch (e) {
      print("[PostService] Error removing like: $e");
      return false;
    }
  }

  Future<List<dynamic>> getLikes(String postId) async {
    try {
      final url = Uri.parse('$baseUrl/posts/$postId/likes');
      final res = await http.get(url);
      _printRawResponse("GET /posts/$postId/likes", res);

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      print("[PostService] Error fetching likes: $e");
    }
    return [];
  }

  Future<bool> hasLiked(String postId, String userId) async {
    try {
      final url = Uri.parse('$baseUrl/posts/$postId/hasLiked/$userId');
      final res = await http.get(url);
      _printRawResponse("GET /posts/$postId/hasLiked/$userId", res);

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body is Map && body.containsKey('liked')) {
          return body['liked'] == true;
        }
      }
    } catch (e) {
      print("[PostService] Error checking like: $e");
    }
    return false;
  }

  Future<List<dynamic>> getFollowingPosts(String userId, {int page = 1, int limit = 20}) async {
    try {
      final url = Uri.parse('$baseUrl/posts/following/$userId?page=$page&limit=$limit');
      final res = await http.get(url);
      _printRawResponse("GET /posts/following/$userId", res);

      if (res.statusCode == 200) {
        return jsonDecode(res.body) as List;
      }
    } catch (e) {
      print("[PostService] Error fetching following posts: $e");
    }
    return [];
  }
}
