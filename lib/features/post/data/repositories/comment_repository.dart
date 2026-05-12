import '../datasources/comment_remote_datasource.dart';
import '../models/comment_model.dart';

class CommentRepository {
  final CommentRemoteDataSource remoteDataSource;

  CommentRepository({required this.remoteDataSource});

  Future<List<CommentModel>> getComments({
    required String token,
    required String postId,
    int page = 1,
    int limit = 10,
    String sort = 'newest',
  }) {
    return remoteDataSource.getComments(
      token: token,
      postId: postId,
      page: page,
      limit: limit,
      sort: sort,
    );
  }

  Future<CommentModelLikeResult> toggleLikeComment({
    required String token,
    required String commentId,
  }) {
    return remoteDataSource.toggleLikeComment(
      token: token,
      commentId: commentId,
    );
  }

  Future<CommentModel> pinComment({
    required String token,
    required String commentId,
  }) {
    return remoteDataSource.pinComment(token: token, commentId: commentId);
  }

  Future<void> unpinComment({
    required String token,
    required String commentId,
  }) {
    return remoteDataSource.unpinComment(token: token, commentId: commentId);
  }

  Future<List<CommentModel>> getReplies({
    required String token,
    required String commentId,
    int page = 1,
    int limit = 10,
  }) {
    return remoteDataSource.getReplies(
      token: token,
      commentId: commentId,
      page: page,
      limit: limit,
    );
  }

  Future<CommentModel> createComment({
    required String token,
    required String postId,
    required String content,
    String? parentComment,
    String? replyToComment,
    String? replyToUser,
  }) {
    return remoteDataSource.createComment(
      token: token,
      postId: postId,
      content: content,
      parentComment: parentComment,
      replyToComment: replyToComment,
      replyToUser: replyToUser,
    );
  }

  Future<CommentModel> editComment({
    required String token,
    required String commentId,
    required String content,
  }) {
    return remoteDataSource.editComment(
      token: token,
      commentId: commentId,
      content: content,
    );
  }

  Future<void> deleteComment({
    required String token,
    required String commentId,
  }) {
    return remoteDataSource.deleteComment(token: token, commentId: commentId);
  }

  Future<CommentModel> undoDeleteComment({
    required String token,
    required String commentId,
  }) {
    return remoteDataSource.undoDeleteComment(
      token: token,
      commentId: commentId,
    );
  }

  Future<void> hideComment({required String token, required String commentId}) {
    return remoteDataSource.hideComment(token: token, commentId: commentId);
  }

  Future<void> unhideComment({
    required String token,
    required String commentId,
  }) {
    return remoteDataSource.unhideComment(token: token, commentId: commentId);
  }

  Future<bool> toggleAllowComments({
    required String token,
    required String postId,
    required bool allowComments,
  }) {
    return remoteDataSource.toggleAllowComments(
      token: token,
      postId: postId,
      allowComments: allowComments,
    );
  }
}
