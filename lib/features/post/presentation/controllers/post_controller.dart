import 'package:flutter/material.dart';

import '../../data/datasources/post_remote_datasource.dart';
import '../../data/models/post_model.dart';
import '../../data/models/PendingPostModel.dart';

class PostController extends ChangeNotifier {
  final PostRemoteDataSource postRemoteDataSource;

  PostController({required this.postRemoteDataSource});

  List<PostModel> posts = [];
  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasMore = true;
  String? nextCursor;
  String? error;
  bool isCreatingPost = false;
  final List<PendingPostModel> pendingPosts = [];

  Future<void> loadFeedPosts(String token) async {
    try {
      isLoading = true;
      error = null;
      nextCursor = null;
      hasMore = true;
      notifyListeners();

      final result = await postRemoteDataSource.getFeedPosts(token);

      posts = result.posts;
      nextCursor = result.nextCursor;
      hasMore = result.hasMore;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreFeedPosts(String token) async {
    if (isLoadingMore || !hasMore || nextCursor == null) return;

    try {
      isLoadingMore = true;
      notifyListeners();

      final result = await postRemoteDataSource.getFeedPosts(
        token,
        cursor: nextCursor,
      );

      posts.addAll(result.posts);
      nextCursor = result.nextCursor;
      hasMore = result.hasMore;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoadingMore = false;
      notifyListeners();
    }
  }

  void removePendingPost(String tempId) {
    pendingPosts.removeWhere((item) => item.tempId == tempId);
    notifyListeners();
  }

  Future<void> retryPendingPost({
    required String token,
    required PendingPostModel pendingPost,
  }) async {
    try {
      pendingPost.isUploading = true;
      pendingPost.isFailed = false;
      notifyListeners();

      await Future.delayed(const Duration(seconds: 3)); // test UI, sau xoá

      final newPost = await postRemoteDataSource.createPost(
        token: token,
        caption: pendingPost.caption,
        location: pendingPost.location,
        imagePaths: pendingPost.imagePaths,
        allowComments: pendingPost.allowComments,
        hideLikeCount: pendingPost.hideLikeCount,
        hideShare: pendingPost.hideShare,
        visibility: pendingPost.visibility,
        allowedUsers: pendingPost.allowedUsers,
        mentions: pendingPost.mentions,
      );

      pendingPosts.removeWhere((item) => item.tempId == pendingPost.tempId);
      posts.insert(0, newPost);

      notifyListeners();
    } catch (e) {
      pendingPost.isUploading = false;
      pendingPost.isFailed = true;
      error = e.toString();

      notifyListeners();
    }
  }

  Future<bool> createPost({
    required String token,
    required String caption,
    required String location,
    required List<String> imagePaths,
    required bool allowComments,
    required bool hideLikeCount,
    required bool hideShare,
    required String visibility,
    required List<String> allowedUsers,
    required List<String> mentions,
  }) async {
    final pendingPost = PendingPostModel(
      tempId: DateTime.now().millisecondsSinceEpoch.toString(),
      caption: caption,
      location: location,
      imagePaths: imagePaths,
      allowComments: allowComments,
      hideLikeCount: hideLikeCount,
      hideShare: hideShare,
      visibility: visibility,
      allowedUsers: allowedUsers,
      mentions: mentions,
    );

    try {
      isCreatingPost = true;
      error = null;

      pendingPosts.insert(0, pendingPost);
      notifyListeners();
      await Future.delayed(const Duration(seconds: 3));

      final newPost = await postRemoteDataSource.createPost(
        token: token,
        caption: caption,
        location: location,
        imagePaths: imagePaths,
        allowComments: allowComments,
        hideLikeCount: hideLikeCount,
        hideShare: hideShare,
        visibility: visibility,
        allowedUsers: allowedUsers,
        mentions: mentions,
      );

      pendingPosts.removeWhere((item) => item.tempId == pendingPost.tempId);
      posts.insert(0, newPost);

      return true;
    } catch (e) {
      pendingPost.isUploading = false;
      pendingPost.isFailed = true;
      error = e.toString();

      return false;
    } finally {
      isCreatingPost = false;
      notifyListeners();
    }
  }
}
