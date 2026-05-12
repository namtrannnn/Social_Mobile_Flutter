import 'package:flutter/material.dart';
import '../../data/models/comment_model.dart';
import '../../data/repositories/comment_repository.dart';

class CommentController extends ChangeNotifier {
  final CommentRepository repository;

  CommentController({required this.repository});
  void _updateLikeState({
    required String commentId,
    required int likesCount,
    required bool isLiked,
  }) {
    final index = _comments.indexWhere((c) => c.id == commentId);

    if (index != -1) {
      final comment = _comments[index];

      _comments[index] = comment.copyWith(
        likesCount: likesCount,
        isLiked: isLiked,
      );

      return;
    }

    for (int i = 0; i < _comments.length; i++) {
      final replies = List<CommentModel>.from(_comments[i].replies);

      final replyIndex = replies.indexWhere((r) => r.id == commentId);

      if (replyIndex != -1) {
        replies[replyIndex] = replies[replyIndex].copyWith(
          likesCount: likesCount,
          isLiked: isLiked,
        );

        _comments[i] = _comments[i].copyWith(replies: replies);

        return;
      }
    }
  }

  final List<CommentModel> _comments = [];
  List<CommentModel> get comments => _comments;

  bool isLoading = false;
  bool isSending = false;
  bool hasMore = true;
  int page = 1;
  String currentSort = 'newest';
  String? errorMessage;

  Future<void> loadComments({
    required String token,
    required String postId,
    bool refresh = false,
    String? sort,
  }) async {
    if (isLoading) return;
    if (sort != null) {
      currentSort = sort;
    }
    if (refresh) {
      page = 1;
      hasMore = true;
      _comments.clear();
      notifyListeners();
    }

    if (!hasMore) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await repository.getComments(
        token: token,
        postId: postId,
        page: page,
        limit: 10,
        sort: currentSort,
      );

      if (result.length < 10) {
        hasMore = false;
      }

      _comments.addAll(result);
      page++;
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  Future<CommentModel?> createComment({
    required String token,
    required String postId,
    required String content,
    String? parentComment,
    String? replyToComment,
    String? replyToUser,
  }) async {
    final text = content.trim();
    if (text.isEmpty) return null;

    isSending = true;
    notifyListeners();

    try {
      final newComment = await repository.createComment(
        token: token,
        postId: postId,
        content: text,
        parentComment: parentComment,
        replyToComment: replyToComment,
        replyToUser: replyToUser,
      );

      if (parentComment == null) {
        _comments.insert(0, newComment);
      } else {
        final index = _comments.indexWhere((c) => c.id == parentComment);
        if (index != -1) {
          final parent = _comments[index];
          final replies = List<CommentModel>.from(parent.replies);
          replies.add(newComment);
          _comments[index] = parent.copyWith(
            replies: replies,
            repliesCount: parent.repliesCount + 1,
          );
        }
      }

      isSending = false;
      notifyListeners();
      return newComment;
    } catch (e) {
      errorMessage = e.toString();
      isSending = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> editComment({
    required String token,
    required String commentId,
    required String content,
  }) async {
    final text = content.trim();
    if (text.isEmpty) return;

    try {
      final updated = await repository.editComment(
        token: token,
        commentId: commentId,
        content: text,
      );

      _replaceComment(updated);
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteComment({
    required String token,
    required String commentId,
  }) async {
    try {
      await repository.deleteComment(token: token, commentId: commentId);

      _removeComment(commentId);
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> undoDeleteComment({
    required String token,
    required String commentId,
  }) async {
    try {
      final restored = await repository.undoDeleteComment(
        token: token,
        commentId: commentId,
      );

      if (restored.parentComment == null) {
        _comments.insert(0, restored);
      } else {
        final index = _comments.indexWhere(
          (c) => c.id == restored.parentComment,
        );
        if (index != -1) {
          final parent = _comments[index];
          final replies = List<CommentModel>.from(parent.replies);
          replies.add(restored);
          _comments[index] = parent.copyWith(replies: replies);
        }
      }

      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  void _replaceComment(CommentModel updated) {
    final index = _comments.indexWhere((c) => c.id == updated.id);

    if (index != -1) {
      _comments[index] = updated;
      return;
    }

    for (int i = 0; i < _comments.length; i++) {
      final replies = List<CommentModel>.from(_comments[i].replies);
      final replyIndex = replies.indexWhere((r) => r.id == updated.id);

      if (replyIndex != -1) {
        replies[replyIndex] = updated;
        _comments[i] = _comments[i].copyWith(
          replies: replies,
          repliesCount: (_comments[i].repliesCount - 1).clamp(0, 999999),
        );
        return;
      }
    }
  }

  Future<void> toggleLikeComment({
    required String token,
    required String commentId,
  }) async {
    try {
      final result = await repository.toggleLikeComment(
        token: token,
        commentId: commentId,
      );

      _updateLikeState(
        commentId: result.commentId,
        likesCount: result.likesCount,
        isLiked: result.isLiked,
      );

      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  void _removeComment(String commentId) {
    _comments.removeWhere((c) => c.id == commentId);

    for (int i = 0; i < _comments.length; i++) {
      final replies = List<CommentModel>.from(_comments[i].replies);
      replies.removeWhere((r) => r.id == commentId);
      _comments[i] = _comments[i].copyWith(replies: replies);
    }
  }

  Future<void> pinComment({
    required String token,
    required String commentId,
  }) async {
    try {
      final pinned = await repository.pinComment(
        token: token,
        commentId: commentId,
      );

      _comments.removeWhere((c) => c.id == commentId);

      _comments.insert(0, pinned);

      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> unpinComment({
    required String token,
    required String commentId,
  }) async {
    try {
      await repository.unpinComment(token: token, commentId: commentId);

      final index = _comments.indexWhere((c) => c.id == commentId);

      if (index != -1) {
        final updated = _comments[index].copyWith(
          isPinned: false,
          pinnedAt: null,
        );

        _comments[index] = updated;
      }

      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadReplies({
    required String token,
    required String parentCommentId,
  }) async {
    try {
      final replies = await repository.getReplies(
        token: token,
        commentId: parentCommentId,
      );

      final index = _comments.indexWhere((c) => c.id == parentCommentId);

      if (index != -1) {
        _comments[index] = _comments[index].copyWith(replies: replies);

        notifyListeners();
      }
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> toggleAllowComments({
    required String token,
    required String postId,
    required bool allowComments,
  }) async {
    return repository.toggleAllowComments(
      token: token,
      postId: postId,
      allowComments: allowComments,
    );
  }

  Future<void> hideComment({
    required String token,
    required String commentId,
  }) async {
    try {
      await repository.hideComment(token: token, commentId: commentId);

      final index = _comments.indexWhere((c) => c.id == commentId);

      if (index != -1) {
        _comments[index] = _comments[index].copyWith(status: 'hidden');
      }

      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> unhideComment({
    required String token,
    required String commentId,
  }) async {
    try {
      await repository.unhideComment(token: token, commentId: commentId);

      final index = _comments.indexWhere((c) => c.id == commentId);

      if (index != -1) {
        _comments[index] = _comments[index].copyWith(status: 'active');
      }

      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }
}
