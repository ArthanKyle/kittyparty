import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

class PostService {
  final String baseUrl;

  PostService({String? baseUrl})
      : baseUrl = baseUrl ?? dotenv.env['BASE_URL']!;

  /// Fetch all posts with pagination
  Future<List<dynamic>> getPosts({int page = 1, int limit = 20}) async {
    try {
      final url = Uri.parse('$baseUrl/posts?page=$page&limit=$limit');
      final res = await http.get(url);

      print("[PostService] GET /posts -> ${res.statusCode}");

      if (res.statusCode == 200) {
        return jsonDecode(res.body) as List<dynamic>;
      }
    } catch (e) {
      print("[PostService] Error fetching posts: $e");
    }
    return [];
  }

  /// Fetch a single post by ID
  Future<Map<String, dynamic>?> getPost(String id) async {
    try {
      final url = Uri.parse('$baseUrl/posts/$id');
      final res = await http.get(url);

      print("[PostService] GET /posts/$id -> ${res.statusCode}");

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      print("[PostService] Error fetching post: $e");
    }
    return null;
  }

  /// Create post with optional media (images/videos)
  Future<Map<String, dynamic>?> createPost({
    required Map<String, dynamic> body,
    List<File>? mediaFiles,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/posts');

      // No media — simple JSON request
      if (mediaFiles == null || mediaFiles.isEmpty) {
        final res = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        );
        print("[PostService] POST /posts -> ${res.statusCode}");
        if (res.statusCode == 201 || res.statusCode == 200) {
          return jsonDecode(res.body);
        }
        return null;
      }

      // With media — multipart request
      final request = http.MultipartRequest('POST', url);
      body.forEach((key, value) => request.fields[key] = value.toString());

      for (var file in mediaFiles) {
        final fileName = p.basename(file.path);
        request.files.add(await http.MultipartFile.fromPath('media', file.path, filename: fileName));
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      print("[PostService] POST /posts (multipart) -> ${response.statusCode}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("[PostService] Error creating post: $e");
    }
    return null;
  }

  /// Add media to existing post
  Future<Map<String, dynamic>?> addMedia(String postId, File file) async {
    try {
      final url = Uri.parse('$baseUrl/posts/$postId/media');
      final request = http.MultipartRequest('POST', url);
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      print("[PostService] POST /posts/$postId/media -> ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("[PostService] Error adding media: $e");
    }
    return null;
  }

  /// Fetch post comments
  Future<List<dynamic>> getComments(String postId) async {
    try {
      final url = Uri.parse('$baseUrl/posts/$postId/comments');
      final res = await http.get(url);

      print("[PostService] GET /posts/$postId/comments -> ${res.statusCode}");

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      print("[PostService] Error fetching comments: $e");
    }
    return [];
  }

  /// Add comment
  Future<Map<String, dynamic>?> addComment(String postId, Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('$baseUrl/posts/$postId/comments');
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      print("[PostService] POST /posts/$postId/comments -> ${res.statusCode}");

      if (res.statusCode == 201 || res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      print("[PostService] Error adding comment: $e");
    }
    return null;
  }

  /// Like a post
  Future<bool> addLike(Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('$baseUrl/posts/likes');
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      print("[PostService] POST /posts/likes -> ${res.statusCode}");
      return res.statusCode == 201 || res.statusCode == 200;
    } catch (e) {
      print("[PostService] Error adding like: $e");
      return false;
    }
  }

  /// Remove like
  Future<bool> removeLike(Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('$baseUrl/posts/likes');
      final res = await http.Request('DELETE', url)
        ..headers['Content-Type'] = 'application/json'
        ..body = jsonEncode(data);

      final streamed = await res.send();
      print("[PostService] DELETE /posts/likes -> ${streamed.statusCode}");

      return streamed.statusCode == 200;
    } catch (e) {
      print("[PostService] Error removing like: $e");
      return false;
    }
  }

  /// Get likes
  Future<List<dynamic>> getLikes(String postId) async {
    try {
      final url = Uri.parse('$baseUrl/posts/$postId/likes');
      final res = await http.get(url);

      print("[PostService] GET /posts/$postId/likes -> ${res.statusCode}");

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      print("[PostService] Error fetching likes: $e");
    }
    return [];
  }

  /// Check if user has liked post
  Future<bool> hasLiked(String postId, String userId) async {
    try {
      final url = Uri.parse('$baseUrl/posts/$postId/hasLiked/$userId');
      final res = await http.get(url);

      print("[PostService] GET /posts/$postId/hasLiked/$userId -> ${res.statusCode}");

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
  Future<List<dynamic>> getFollowingPosts(String userId) async {
    try {
      final url = Uri.parse('$baseUrl/posts/following/$userId');
      final res = await http.get(url);

      print("[PostService] GET /posts/following/$userId -> ${res.statusCode}");

      if (res.statusCode == 200) {
        return jsonDecode(res.body) as List;
      }
    } catch (e) {
      print("[PostService] Error fetching following posts: $e");
    }
    return [];
  }


}
