import 'package:flutter/material.dart';

import '../../data/models/profile_model.dart';
import '../../data/models/profile_post_grid_model.dart';
import '../../data/repositories/profile_repository.dart';
import '../../../post/data/models/post_model.dart';

class ProfileController extends ChangeNotifier {
  final ProfileRepository repository;

  ProfileController({required this.repository});

  bool isUpdatingProfile = false;

  // =========================
  // PROFILE STATE
  // =========================

  ProfileModel? myProfile;
  ProfileModel? viewedProfile;

  List<ProfileGridPostModel> myGridPosts = [];
  List<ProfileGridPostModel> viewedGridPosts = [];

  bool isLoadingProfile = false;
  bool isLoadingGrid = false;
  bool isLoadingMoreGrid = false;

  String? errorMessage;

  String? myNextCursor;
  String? viewedNextCursor;

  bool myHasMoreGrid = true;
  bool viewedHasMoreGrid = true;

  // =========================
  // USER FEED POSTS
  // Tạm giữ lại như cũ.
  // Nếu sau này bị lẫn bài viết khi mở detail/feed thì tách tiếp.
  // =========================

  List<PostModel> userFeedPosts = [];

  bool isLoadingUserFeed = false;
  bool isLoadingMoreUserFeed = false;
  bool hasMoreUserFeed = true;

  String? userFeedCursor;

  // =========================
  // LOAD MY PROFILE
  // =========================

  Future<void> loadMyProfile(String token) async {
    isLoadingProfile = true;
    errorMessage = null;
    notifyListeners();

    try {
      myProfile = await repository.getMyProfile(token: token);

      await loadUserPostGrid(
        token: token,
        userId: myProfile!.user.id,
        isMyProfile: true,
        refresh: true,
      );
      await loadMentionedPostGrid(
        token: token,
        userId: myProfile!.user.id,
        isMyProfile: true,
        refresh: true,
      );
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoadingProfile = false;
      notifyListeners();
    }
  }

  // =========================
  // LOAD OTHER USER PROFILE
  // =========================

  Future<void> loadUserProfile({
    required String token,
    required String userId,
  }) async {
    isLoadingProfile = true;
    errorMessage = null;
    notifyListeners();

    try {
      viewedProfile = await repository.getUserProfile(
        token: token,
        userId: userId,
      );

      await loadUserPostGrid(
        token: token,
        userId: userId,
        isMyProfile: false,
        refresh: true,
      );
      await loadMentionedPostGrid(
        token: token,
        userId: userId,
        isMyProfile: false,
        refresh: true,
      );
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoadingProfile = false;
      notifyListeners();
    }
  }

  // =========================
  // LOAD GRID POSTS
  // =========================

  Future<void> loadUserPostGrid({
    required String token,
    required String userId,
    required bool isMyProfile,
    bool refresh = false,
  }) async {
    if (isLoadingGrid || isLoadingMoreGrid) return;

    final currentHasMoreGrid = isMyProfile ? myHasMoreGrid : viewedHasMoreGrid;
    final currentCursor = isMyProfile ? myNextCursor : viewedNextCursor;

    if (refresh) {
      isLoadingGrid = true;

      if (isMyProfile) {
        myNextCursor = null;
        myHasMoreGrid = true;
        myGridPosts = [];
      } else {
        viewedNextCursor = null;
        viewedHasMoreGrid = true;
        viewedGridPosts = [];
      }
    } else {
      if (!currentHasMoreGrid) return;
      isLoadingMoreGrid = true;
    }

    notifyListeners();

    try {
      final posts = await repository.getUserPostGrid(
        token: token,
        userId: userId,
        cursor: refresh ? null : currentCursor,
      );

      if (isMyProfile) {
        if (refresh) {
          myGridPosts = posts;
        } else {
          myGridPosts.addAll(posts);
        }

        if (posts.isNotEmpty) {
          myNextCursor = posts.last.createdAt?.toIso8601String();
        }

        myHasMoreGrid = posts.length >= 30;
      } else {
        if (refresh) {
          viewedGridPosts = posts;
        } else {
          viewedGridPosts.addAll(posts);
        }

        if (posts.isNotEmpty) {
          viewedNextCursor = posts.last.createdAt?.toIso8601String();
        }

        viewedHasMoreGrid = posts.length >= 30;
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoadingGrid = false;
      isLoadingMoreGrid = false;
      notifyListeners();
    }
  }

  // =========================
  // USER POST FEED
  // =========================

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

  // =========================
  // UPDATE MY PROFILE
  // =========================

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

      myProfile = myProfile?.copyWith(user: updatedUser);

      if (viewedProfile?.user.id == updatedUser.id) {
        viewedProfile = viewedProfile?.copyWith(user: updatedUser);
      }

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

  // =========================
  // CLEAR
  // =========================

  void clearMyProfile() {
    myProfile = null;
    myGridPosts = [];
    myNextCursor = null;
    myHasMoreGrid = true;

    myMentionedPosts = [];
    myMentionedCursor = null;
    myHasMoreMentioned = true;

    errorMessage = null;
    notifyListeners();
  }

  void clearViewedProfile() {
    viewedProfile = null;
    viewedGridPosts = [];
    viewedNextCursor = null;
    viewedHasMoreGrid = true;

    viewedMentionedPosts = [];
    viewedMentionedCursor = null;
    viewedHasMoreMentioned = true;

    errorMessage = null;
    notifyListeners();
  }

  List<ProfileGridPostModel> myMentionedPosts = [];
  List<ProfileGridPostModel> viewedMentionedPosts = [];

  String? myMentionedCursor;
  String? viewedMentionedCursor;

  bool isLoadingMentioned = false;
  bool isLoadingMoreMentioned = false;

  bool myHasMoreMentioned = true;
  bool viewedHasMoreMentioned = true;
  Future<void> loadMentionedPostGrid({
    required String token,
    required String userId,
    required bool isMyProfile,
    bool refresh = false,
  }) async {
    if (isLoadingMentioned || isLoadingMoreMentioned) return;

    final currentHasMore = isMyProfile
        ? myHasMoreMentioned
        : viewedHasMoreMentioned;

    final currentCursor = isMyProfile
        ? myMentionedCursor
        : viewedMentionedCursor;

    if (refresh) {
      isLoadingMentioned = true;

      if (isMyProfile) {
        myMentionedCursor = null;
        myHasMoreMentioned = true;
        myMentionedPosts = [];
      } else {
        viewedMentionedCursor = null;
        viewedHasMoreMentioned = true;
        viewedMentionedPosts = [];
      }
    } else {
      if (!currentHasMore) return;
      isLoadingMoreMentioned = true;
    }

    notifyListeners();

    try {
      final posts = await repository.getMentionedPostGrid(
        token: token,
        userId: userId,
        cursor: refresh ? null : currentCursor,
      );

      if (isMyProfile) {
        if (refresh) {
          myMentionedPosts = posts;
        } else {
          myMentionedPosts.addAll(posts);
        }

        if (posts.isNotEmpty) {
          myMentionedCursor = posts.last.createdAt?.toIso8601String();
        }

        myHasMoreMentioned = posts.length >= 30;
      } else {
        if (refresh) {
          viewedMentionedPosts = posts;
        } else {
          viewedMentionedPosts.addAll(posts);
        }

        if (posts.isNotEmpty) {
          viewedMentionedCursor = posts.last.createdAt?.toIso8601String();
        }

        viewedHasMoreMentioned = posts.length >= 30;
      }
    } catch (e) {
      errorMessage = e.toString();
      debugPrint('loadMentionedPostGrid error: $e');
    } finally {
      isLoadingMentioned = false;
      isLoadingMoreMentioned = false;
      notifyListeners();
    }
  }

  void clearProfile() {
    myProfile = null;
    viewedProfile = null;

    myGridPosts = [];
    viewedGridPosts = [];

    myNextCursor = null;
    viewedNextCursor = null;

    myHasMoreGrid = true;
    viewedHasMoreGrid = true;

    errorMessage = null;
    notifyListeners();
  }
}
