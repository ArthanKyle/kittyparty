import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import '../../../core/services/api/post_service.dart';
import '../../auth/model/auth.dart';
import '../model/post.dart';
import '../../../core/utils/user_provider.dart';

class PostViewModel with ChangeNotifier {
  final PostService _service;
  String? currentUserId;

  List<Post> posts = [];
  bool loading = false;
  bool posting = false;
  String? error;

  late final StreamSubscription<User> _userSub;

  PostViewModel({
    required UserProvider userProvider,
    String? currentUserId,
  })  : _service = PostService(),
        currentUserId = currentUserId {

    if (this.currentUserId != null && this.currentUserId!.isNotEmpty) {
      _initialFetch();
    }

    _userSub = userProvider.userStream.listen((user) {
      this.currentUserId = user.userIdentification;
      _initialFetch();
    });
  }

  // INITIAL FETCH
  void _initialFetch() {
    fetchPosts();
    fetchFollowingPosts();
  }

  // FETCH ALL POSTS
  Future<void> fetchPosts() async {
    loading = true;
    notifyListeners();

    try {
      final raw = await _service.getPosts();
      posts = raw.map((e) => Post.fromJson(e)).toList();
      error = null;
    } catch (e) {
      error = e.toString();
    }

    loading = false;
    notifyListeners();
  }

  // FETCH FOLLOWING FEED
  Future<void> fetchFollowingPosts() async {
    if (currentUserId == null || currentUserId!.isEmpty) return;

    loading = true;
    notifyListeners();

    try {
      final raw = await _service.getFollowingPosts(currentUserId!);
      posts = raw.map((e) => Post.fromJson(e)).toList();
      error = null;
    } catch (e) {
      error = e.toString();
    }

    loading = false;
    notifyListeners();
  }

  // CREATE A POST
  Future<bool> createPost({
    required String content,
    List<File>? mediaFiles,
  }) async {
    if (currentUserId == null || currentUserId!.isEmpty) {
      error = "User not loaded. Cannot create post.";
      notifyListeners();
      return false;
    }

    posting = true;
    notifyListeners();

    try {
      final body = {
        'authorId': currentUserId!,
        'content': content,
      };

      final resp = await _service.createPost(
        body: body,
        mediaFiles: mediaFiles,
      );

      if (resp != null && resp['postId'] != null) {
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

  // COMMENTS
  Future<bool> addComment(String postId, String content) async {
    if (currentUserId == null) return false;

    final ok = await _service.addComment(
      postId: postId,
      userId: currentUserId!,
      content: content,
    );

    if (ok) {
      await fetchPosts();
      notifyListeners();
    }

    return ok;
  }

  Future<List<dynamic>> getComments(String postId) {
    return _service.getComments(postId);
  }

  // LIKE / UNLIKE
  Future<bool> likePost(String postId) async {
    if (currentUserId == null) return false;

    final ok = await _service.likePost(postId, currentUserId!);

    if (ok) {
      _applyLocalLike(postId, true);
      notifyListeners();
    }

    return ok;
  }

  Future<bool> unlikePost(String postId) async {
    if (currentUserId == null) return false;

    final ok = await _service.unlikePost(postId, currentUserId!);

    if (ok) {
      _applyLocalLike(postId, false);
      notifyListeners();
    }

    return ok;
  }

  Future<bool> hasLiked(String postId) async {
    if (currentUserId == null) return false;
    return _service.hasLiked(postId, currentUserId!);
  }

  Future<List<dynamic>> getLikes(String postId) {
    return _service.getLikes(postId);
  }

  // LOCAL LIKE UPDATE - DIRECT MUTATION
  void _applyLocalLike(String postId, bool liked) {
    final index = posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final post = posts[index];
    final currentCount = post.likesCount ?? 0;

    final newCount = liked ? currentCount + 1 : currentCount - 1;

    posts[index].likesCount = newCount < 0 ? 0 : newCount;
  }

  @override
  void dispose() {
    _userSub.cancel();
    super.dispose();
  }
}
