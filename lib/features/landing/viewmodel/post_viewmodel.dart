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

  List<Post> recommendedPosts = [];
  List<Post> followingPosts = [];

  bool loadingRecommended = false;
  bool loadingFollowing = false;
  bool posting = false;

  String? error;

  late final StreamSubscription<User> _userSub;
  StreamSubscription? _likeSub;
  StreamSubscription? _commentSub;

  PostViewModel({required UserProvider userProvider})
      : _service = PostService() {
    _userSub = userProvider.userStream.listen((user) {
      currentUserId = user.userIdentification;

      fetchRecommendedPosts();
      fetchFollowingPosts();

      _attachSocketStreams(userProvider);
    });
  }

  final Set<String> hiddenPostIds = {};

  void hidePost(String postId) {
    hiddenPostIds.add(postId);
    recommendedPosts.removeWhere((p) => p.id == postId);
    followingPosts.removeWhere((p) => p.id == postId);
    notifyListeners();
  }

  void _attachSocketStreams(UserProvider provider) {
    _likeSub?.cancel();
    _commentSub?.cancel();

    final socket = provider.socketService;
    _likeSub = socket.likeStream.listen((data) {
      final postId = data['postId'];
      final count = data['likesCount'];
      _applyLikeUpdate(postId, count);
    });

    _commentSub = socket.commentStream.listen((data) {
      final postId = data['postId'];
      final count = data['commentsCount'];
      _applyCommentUpdate(postId, count);
    });
  }

  Future<void> fetchRecommendedPosts() async {
    if (currentUserId == null) return;

    loadingRecommended = true;
    notifyListeners();

    try {
      final raw = await _service.getPosts(currentUserId!);
      recommendedPosts = raw.map((e) => Post.fromJson(e)).toList();


      recommendedPosts = recommendedPosts.where((p) => p.authorId != currentUserId).toList();

      error = null;
    } catch (e) {
      error = e.toString();
    }

    loadingRecommended = false;
    notifyListeners();
  }

  Future<void> fetchFollowingPosts() async {
    if (currentUserId == null) return;

    loadingFollowing = true;
    notifyListeners();

    try {
      final raw = await _service.getFollowingPosts(currentUserId!);
      followingPosts = raw.map((e) => Post.fromJson(e)).toList();
      error = null;
    } catch (e) {
      error = e.toString();
    }

    loadingFollowing = false;
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
      final resp = await _service.createPost(
        body: {
          'authorId': currentUserId!,
          'content': content,
        },
        mediaFiles: mediaFiles,
      );

      if (resp != null) {
        await fetchRecommendedPosts();
        await fetchFollowingPosts();
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

  Future<bool> addComment(String postId, String content) async {
    if (currentUserId == null) return false;

    final ok = await _service.addComment(
      postId: postId,
      userId: currentUserId!,
      content: content,
    );

    if (ok) {
      await fetchRecommendedPosts();
      await fetchFollowingPosts();
    }

    notifyListeners();
    return ok;
  }

  Future<List<dynamic>> getComments(String postId) {
    return _service.getComments(postId);
  }

  Future<bool> likePost(String postId) async {
    if (currentUserId == null) return false;

    final ok = await _service.likePost(postId, currentUserId!);
    if (ok) _updateLocalLike(postId, true);

    notifyListeners();
    return ok;
  }

  Future<bool> unlikePost(String postId) async {
    if (currentUserId == null) return false;

    final ok = await _service.unlikePost(postId, currentUserId!);
    if (ok) _updateLocalLike(postId, false);

    notifyListeners();
    return ok;
  }

  Future<bool> hasLiked(String postId) async {
    if (currentUserId == null) return false;
    return _service.hasLiked(postId, currentUserId!);
  }

  Future<List<dynamic>> getLikes(String postId) {
    return _service.getLikes(postId);
  }

  void _updateLocalLike(String postId, bool liked) {
    final lists = [recommendedPosts, followingPosts];

    for (final list in lists) {
      final index = list.indexWhere((p) => p.id == postId);
      if (index != -1) {
        final post = list[index];
        post.likesCount = liked
            ? post.likesCount + 1
            : (post.likesCount - 1).clamp(0, 999999);
      }
    }
  }

  void _applyLikeUpdate(String postId, int count) {
    final lists = [recommendedPosts, followingPosts];

    for (final list in lists) {
      final index = list.indexWhere((p) => p.id == postId);
      if (index != -1) list[index].likesCount = count;
    }

    notifyListeners();
  }

  void _applyCommentUpdate(String postId, int count) {
    final lists = [recommendedPosts, followingPosts];

    for (final list in lists) {
      final index = list.indexWhere((p) => p.id == postId);
      if (index != -1) list[index].commentsCount = count;
    }

    notifyListeners();
  }

  Future<bool> deletePost(String postId) async {
    if (currentUserId == null) return false;

    final ok = await _service.deletePost(postId);

    if (ok) {
      recommendedPosts.removeWhere((p) => p.id == postId);
      followingPosts.removeWhere((p) => p.id == postId);
      notifyListeners();
    }

    return ok;
  }


  @override
  void dispose() {
    _userSub.cancel();
    _likeSub?.cancel();
    _commentSub?.cancel();
    super.dispose();
  }
}
