import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/services/api/post_service.dart';
import '../model/post.dart';

class PostViewModel with ChangeNotifier {
  final PostService _service;
  final String currentUserId; // ensures author ID is always available

  List<Post> posts = [];
  bool loading = false;
  bool posting = false;
  String? error;

  PostViewModel({
    required this.currentUserId,
    PostService? service,
  }) : _service = service ?? PostService();

  /// Fetch all posts
  Future<void> fetchPosts() async {
    loading = true;
    notifyListeners();
    try {
      final data = await _service.getPosts();
      posts = data.map((e) => Post.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Fetch posts from followed users
  Future<void> fetchFollowingPosts() async {
    if (currentUserId.isEmpty) return;
    loading = true;
    notifyListeners();
    try {
      final data = await _service.getFollowingPosts(currentUserId);
      posts = data.map((e) => Post.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Create a new post with optional media
  Future<bool> createPost({
    required String content,
    List<File>? mediaFiles,
  }) async {
    if (currentUserId.isEmpty) {
      error = "User ID is missing. Cannot create post.";
      return false;
    }

    posting = true;
    notifyListeners();

    try {
      final body = {'content': content, 'author': currentUserId}; // match backend key
      print('[PostViewModel] Creating post with author: $currentUserId');

      final resp = await _service.createPost(body: body, mediaFiles: mediaFiles);

      if (resp != null) {
        posts.insert(0, Post.fromJson(resp as Map<String, dynamic>));
        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      posting = false;
      notifyListeners();
    }
  }
}
