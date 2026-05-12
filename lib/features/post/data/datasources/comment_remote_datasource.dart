import 'package:dio/dio.dart';

import '../models/comment_model.dart';
import '../../../../core/network/dio_client.dart';

class CommentModelLikeResult {
  final String commentId;
  final int likesCount;
  final bool isLiked;

  CommentModelLikeResult({
    required this.commentId,
    required this.likesCount,
    required this.isLiked,
  });

  factory CommentModelLikeResult.fromJson(Map<String, dynamic> json) {
    return CommentModelLikeResult(
      commentId: json['commentId']?.toString() ?? '',
      likesCount: json['likesCount'] ?? 0,
      isLiked: json['isLiked'] ?? false,
    );
  }
}

class CommentRemoteDataSource {
  final Dio dio = DioClient().dio;

  CommentRemoteDataSource();

  Future<List<CommentModel>> getComments({
    required String token,
    required String postId,
    int page = 1,
    int limit = 10,
    String sort = 'newest',
  }) async {
    final res = await dio.get(
      '/post/comment/$postId',
      queryParameters: {'page': page, 'limit': limit, 'sort': sort},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    final List data = res.data['data'] ?? [];
    return data.map((e) => CommentModel.fromJson(e)).toList();
  }

  Future<CommentModel> createComment({
    required String token,
    required String postId,
    required String content,
    String? parentComment,
    String? replyToComment,
    String? replyToUser,
  }) async {
    final res = await dio.post(
      '/post/comment/$postId',
      data: {
        'content': content,
        if (parentComment != null) 'parentComment': parentComment,
        if (replyToComment != null) 'replyToComment': replyToComment,
        if (replyToUser != null) 'replyToUser': replyToUser,
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return CommentModel.fromJson(res.data['data']);
  }

  Future<CommentModel> editComment({
    required String token,
    required String commentId,
    required String content,
  }) async {
    final res = await dio.patch(
      '/post/comment/edit/$commentId',
      data: {'content': content},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return CommentModel.fromJson(res.data['data']);
  }

  Future<void> deleteComment({
    required String token,
    required String commentId,
  }) async {
    await dio.patch(
      '/post/comment/delete/$commentId',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<CommentModel> undoDeleteComment({
    required String token,
    required String commentId,
  }) async {
    final res = await dio.patch(
      '/post/comment/undo-delete/$commentId',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return CommentModel.fromJson(res.data['data']);
  }

  Future<void> hideComment({
    required String token,
    required String commentId,
  }) async {
    await dio.patch(
      '/post/comment/hide/$commentId',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<CommentModelLikeResult> toggleLikeComment({
    required String token,
    required String commentId,
  }) async {
    final res = await dio.patch(
      '/post/comment/like/$commentId',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return CommentModelLikeResult.fromJson(res.data['data']);
  }

  Future<CommentModel> pinComment({
    required String token,
    required String commentId,
  }) async {
    final res = await dio.patch(
      '/post/comment/pin/$commentId',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return CommentModel.fromJson(res.data['data']);
  }

  Future<void> unpinComment({
    required String token,
    required String commentId,
  }) async {
    await dio.patch(
      '/post/comment/unpin/$commentId',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<List<CommentModel>> getReplies({
    required String token,
    required String commentId,
    int page = 1,
    int limit = 10,
  }) async {
    final res = await dio.get(
      '/post/comment/replies/$commentId',
      queryParameters: {'page': page, 'limit': limit},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    final List data = res.data['data'] ?? [];
    return data.map((e) => CommentModel.fromJson(e)).toList();
  }

  Future<bool> toggleAllowComments({
    required String token,
    required String postId,
    required bool allowComments,
  }) async {
    final res = await dio.patch(
      '/post/comment/allow/$postId',
      data: {'allowComments': allowComments},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return res.data['data']['allowComments'] ?? allowComments;
  }

  Future<void> unhideComment({
    required String token,
    required String commentId,
  }) async {
    await dio.patch(
      '/post/comment/unhide/$commentId',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }
}
