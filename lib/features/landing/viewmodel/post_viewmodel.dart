import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/services/api/post_service.dart';
import '../model/post.dart';

class PostViewModel with ChangeNotifier {
  final PostService _service;
  final String currentUserId;

  List<Post> posts = [];
  bool loading = false;
  bool posting = false;
  String? error;

  PostViewModel({required this.currentUserId})
      : _service = PostService();

  // ---------------- FETCH POSTS ----------------
  Future<void> fetchPosts() async {
    loading = true;
    notifyListeners();

    try {
      final raw = await _service.getPosts();
      posts = raw.map((e) => Post.fromJson(e)).toList();
    } catch (e) {
      error = e.toString();
    }

    loading = false;
    notifyListeners();
  }

  // ---------------- CREATE POST ----------------
  Future<bool> createPost({
    required String content,
    List<File>? mediaFiles,
  }) async {
    posting = true;
    notifyListeners();

    try {
      final body = {
        'authorId': currentUserId,   // FIXED
        'content': content,
      };

      final resp = await _service.createPost(
        body: body,
        mediaFiles: mediaFiles,
      );

      if (resp != null && resp['postId'] != null) {
        // fetch the new post
        await fetchPosts();
        posting = false;
        notifyListeners();
        return true;
      }

      posting = false;
      notifyListeners();
      return false;
    } catch (e) {
      error = e.toString();
      posting = false;
      notifyListeners();
      return false;
    }
  }
  Future<void> fetchFollowingPosts() async {
    if (currentUserId.isEmpty) return;

    loading = true;
    notifyListeners();

    try {
      final raw = await _service.getFollowingPosts(currentUserId);
      posts = raw.map((e) => Post.fromJson(e)).toList();
    } catch (e) {
      error = e.toString();
    }

    loading = false;
    notifyListeners();
  }

}
