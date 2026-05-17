import 'package:flutter/material.dart';

import '../../data/models/profile_model.dart';
import '../../data/models/profile_post_grid_model.dart';
import '../../data/repositories/profile_repository.dart';
import '../../../post/data/models/post_model.dart';

class ProfileController extends ChangeNotifier {
  final ProfileRepository repository;
  bool isUpdatingProfile = false;
  ProfileController({required this.repository});
  List<PostModel> userFeedPosts = [];

  bool isLoadingUserFeed = false;
  bool isLoadingMoreUserFeed = false;
  bool hasMoreUserFeed = true;

  String? userFeedCursor;
  ProfileModel? profile;
  List<ProfileGridPostModel> gridPosts = [];

  bool isLoadingProfile = false;
  bool isLoadingGrid = false;
  bool isLoadingMoreGrid = false;

  String? errorMessage;
  String? nextCursor;
  bool hasMoreGrid = true;

  Future<void> loadMyProfile(String token) async {
    isLoadingProfile = true;
    errorMessage = null;
    notifyListeners();

    try {
      profile = await repository.getMyProfile(token: token);

      await loadUserPostGrid(
        token: token,
        userId: profile!.user.id,
        refresh: true,
      );
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoadingProfile = false;
      notifyListeners();
    }
  }

  Future<void> loadUserProfile({
    required String token,
    required String userId,
  }) async {
    isLoadingProfile = true;
    errorMessage = null;
    notifyListeners();

    try {
      profile = await repository.getUserProfile(token: token, userId: userId);

      await loadUserPostGrid(token: token, userId: userId, refresh: true);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoadingProfile = false;
      notifyListeners();
    }
  }

  Future<void> loadUserPostGrid({
    required String token,
    required String userId,
    bool refresh = false,
  }) async {
    if (isLoadingGrid || isLoadingMoreGrid) return;

    if (refresh) {
      isLoadingGrid = true;
      nextCursor = null;
      hasMoreGrid = true;
      gridPosts = [];
    } else {
      if (!hasMoreGrid) return;
      isLoadingMoreGrid = true;
    }

    notifyListeners();

    try {
      final posts = await repository.getUserPostGrid(
        token: token,
        userId: userId,
        cursor: refresh ? null : nextCursor,
      );

      if (refresh) {
        gridPosts = posts;
      } else {
        gridPosts.addAll(posts);
      }

      if (posts.isNotEmpty) {
        nextCursor = posts.last.createdAt?.toIso8601String();
      }

      hasMoreGrid = posts.length >= 30;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoadingGrid = false;
      isLoadingMoreGrid = false;
      notifyListeners();
    }
  }

  Future<void> loadUserPostFeed({
    required String token,
    required String userId,
    bool refresh = false,
  }) async {
    if (isLoadingUserFeed) return;

    isLoadingUserFeed = true;

    if (refresh) {
      userFeedPosts.clear();
      userFeedCursor = null;
      hasMoreUserFeed = true;
    }

    notifyListeners();

    try {
      final posts = await repository.getUserPostFeed(
        token: token,
        userId: userId,
        limit: 20,
        cursor: userFeedCursor,
      );

      if (refresh) {
        userFeedPosts = posts;
      } else {
        userFeedPosts.addAll(posts);
      }

      if (posts.isNotEmpty) {
        userFeedCursor = posts.last.createdAt?.toIso8601String();
      }

      hasMoreUserFeed = posts.length == 20;
    } catch (e) {
      debugPrint('loadUserPostFeed error: $e');
    } finally {
      isLoadingUserFeed = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreUserPostFeed({
    required String token,
    required String userId,
  }) async {
    if (isLoadingMoreUserFeed || !hasMoreUserFeed) return;

    isLoadingMoreUserFeed = true;
    notifyListeners();

    try {
      final posts = await repository.getUserPostFeed(
        token: token,
        userId: userId,
        limit: 20,
        cursor: userFeedCursor,
      );

      userFeedPosts.addAll(posts);

      if (posts.isNotEmpty) {
        userFeedCursor = posts.last.createdAt?.toIso8601String();
      }

      hasMoreUserFeed = posts.length == 20;
    } catch (e) {
      debugPrint('loadMoreUserPostFeed error: $e');
    } finally {
      isLoadingMoreUserFeed = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    required String token,
    required String fullName,
    required String username,
    required String bio,
    required bool isPrivate,
    String? avatarPath,
  }) async {
    if (isUpdatingProfile) return false;

    isUpdatingProfile = true;
    errorMessage = null;
    notifyListeners();

    try {
      final updatedUser = await repository.updateProfile(
        token: token,
        fullName: fullName.trim(),
        username: username.trim().toLowerCase(),
        bio: bio.trim(),
        isPrivate: isPrivate,
        avatarPath: avatarPath,
      );

      profile = profile?.copyWith(user: updatedUser);

      isUpdatingProfile = false;
      notifyListeners();

      return true;
    } catch (e) {
      errorMessage = e.toString();

      isUpdatingProfile = false;
      notifyListeners();

      return false;
    }
  }

  void clearProfile() {
    profile = null;
    gridPosts = [];
    errorMessage = null;
    nextCursor = null;
    hasMoreGrid = true;
    notifyListeners();
  }
}
