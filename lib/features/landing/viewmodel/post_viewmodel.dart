import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/services/api/post_service.dart';
import '../model/post.dart';

class PostViewModel with ChangeNotifier {
  final PostService _service;

  List<Post> posts = [];
  bool loading = false;
  bool posting = false;
  String? error;

  PostViewModel({PostService? service}) : _service = service ?? PostService();

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

  Future<bool> createPost({
    required String content,
    required String authorId,
    List<File>? mediaFiles,
  }) async {
    posting = true;
    notifyListeners();
    try {
      final body = {'content': content, 'author': authorId};
      final resp = await _service.createPost(body: body, mediaFiles: mediaFiles);
      // Optionally insert new post to top
      posts.insert(0, Post.fromJson(resp as Map<String, dynamic>));
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      posting = false;
      notifyListeners();
    }
  }

  Future<void> addLike(String postId, String userId) async {
    try {
      await _service.addLike({'postId': postId, 'userId': userId});
      // optimistic update: increase like count locally (simple approach)
      final idx = posts.indexWhere((p) => p.id == postId);
      if (idx != -1) {
        final p = posts[idx];
        posts[idx] = Post(
          id: p.id,
          authorId: p.authorId,
          content: p.content,
          media: p.media,
          likesCount: p.likesCount + 1,
          commentsCount: p.commentsCount,
          createdAt: p.createdAt,
        );
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> removeLike(String postId, String userId) async {
    try {
      await _service.removeLike({'postId': postId, 'userId': userId});
      final idx = posts.indexWhere((p) => p.id == postId);
      if (idx != -1) {
        final p = posts[idx];
        posts[idx] = Post(
          id: p.id,
          authorId: p.authorId,
          content: p.content,
          media: p.media,
          likesCount: (p.likesCount - 1).clamp(0, 999999),
          commentsCount: p.commentsCount,
          createdAt: p.createdAt,
        );
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> fetchFollowingPosts(String userId) async {
    loading = true;
    notifyListeners();
    try {
      final data = await _service.getFollowingPosts(userId);
      posts = data.map((e) => Post.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

}
