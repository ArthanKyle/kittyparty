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

  void _initialFetch() {
    fetchPosts();
    fetchFollowingPosts();
  }

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

  @override
  void dispose() {
    _userSub.cancel();
    super.dispose();
  }
}
