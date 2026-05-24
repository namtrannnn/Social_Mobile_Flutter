import 'package:dio/dio.dart';
import 'dart:convert';
import '../../../../core/config/api_config.dart';
import '../models/post_model.dart';
import '../models/post_like_user_model.dart';

class FeedPostResult {
  final List<PostModel> posts;
  final String? nextCursor;
  final bool hasMore;

  FeedPostResult({
    required this.posts,
    required this.nextCursor,
    required this.hasMore,
  });
}

class LikedUsersResult {
  final List<PostLikeUserModel> users;
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  LikedUsersResult({
    required this.users,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  bool get hasMore => page < totalPages;
}

class PostRemoteDataSource {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );

  // [GET] getFeedPosts
  Future<FeedPostResult> getFeedPosts(String token, {String? cursor}) async {
    try {
      final response = await dio.get(
        '/post/feed',
        queryParameters: {
          'limit': 10,
          if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      // print('GET FEED STATUS: ${response.statusCode}');
      // print('GET FEED DATA: ${response.data}');

      final data = response.data;

      final List list = data['data'] ?? [];
      final pagination = data['pagination'] ?? {};

      return FeedPostResult(
        posts: list.map((e) => PostModel.fromJson(e)).toList(),
        nextCursor: pagination['nextCursor'],
        hasMore: pagination['hasMore'] ?? false,
      );
    } on DioException catch (e) {
      // print('GET FEED ERROR: ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? 'Lấy feed thất bại');
    }
  }

  // [POST] createPost
  Future<PostModel> createPost({
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
    try {
      final List<MultipartFile> images = [];

      for (final path in imagePaths) {
        images.add(
          await MultipartFile.fromFile(path, filename: path.split('/').last),
        );
      }

      final formData = FormData.fromMap({
        'caption': caption,
        'location': location,

        'allowComments': allowComments.toString(),
        'hideLikeCount': hideLikeCount.toString(),
        'hideShare': hideShare.toString(),
        'visibility': visibility,

        // tạm thời để rỗng
        'mentions': jsonEncode(mentions),
        'allowedUsers': jsonEncode(allowedUsers),

        // QUAN TRỌNG
        // phải trùng upload.array('images')
        'images': images,
      });

      final response = await dio.post(
        '/post/create',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      // print('CREATE POST STATUS: ${response.statusCode}');
      // print('CREATE POST DATA: ${response.data}');

      final data = response.data['data'];

      return PostModel.fromJson(data);
    } on DioException catch (e) {
      // print('CREATE POST ERROR: ${e.response?.data}');

      throw Exception(e.response?.data['message'] ?? 'Tạo bài viết thất bại');
    }
  }

  // [POST] toggleLike
  Future<Map<String, dynamic>> toggleLike({
    required String token,
    required String postId,
  }) async {
    try {
      final response = await dio.post(
        '/post/toggle-like/$postId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return response.data['data'];
    } on DioException catch (e) {
      // print('TOGGLE LIKE ERROR: ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? 'Thao tác like thất bại');
    }
  }

  // [GET] UsersLikePost

  Future<LikedUsersResult> getUsersLikedPost({
    required String token,
    required String postId,
    int page = 1,
    int limit = 20,
    String search = '',
  }) async {
    try {
      final response = await dio.get(
        '/post/likes/$postId',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (search.trim().isNotEmpty) 'search': search.trim(),
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final List list = response.data['data'] ?? [];
      final meta = response.data['meta'] ?? {};

      return LikedUsersResult(
        users: list.map((e) => PostLikeUserModel.fromJson(e)).toList(),
        page: meta['page'] ?? page,
        limit: meta['limit'] ?? limit,
        total: meta['total'] ?? 0,
        totalPages: meta['totalPages'] ?? 1,
      );
    } on DioException catch (e) {
      // print('GET LIKED USERS ERROR: ${e.response?.data}');
      throw Exception(
        e.response?.data['message'] ?? 'Lấy danh sách người thích thất bại',
      );
    }
  }

  Future<PostModel> editPost({
    required String token,
    required String postId,
    required String caption,
    required String location,
    required bool allowComments,
    required bool hideLikeCount,
    required bool hideShare,
    required String visibility,
    required List<String> allowedUsers,
    required List<String> mentions,
    required List<String> keepMediaIds,
    required List<String> imagePaths,
  }) async {
    try {
      final List<MultipartFile> images = [];

      for (final path in imagePaths) {
        images.add(
          await MultipartFile.fromFile(path, filename: path.split('/').last),
        );
      }

      final formData = FormData.fromMap({
        'caption': caption,
        'location': location,
        'allowComments': allowComments.toString(),
        'hideLikeCount': hideLikeCount.toString(),
        'hideShare': hideShare.toString(),
        'visibility': visibility,
        'allowedUsers': jsonEncode(allowedUsers),
        'mentions': jsonEncode(mentions),
        'keepMediaIds': jsonEncode(keepMediaIds),
        'images': images,
      });

      final response = await dio.patch(
        '/post/edit/$postId',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      final data = response.data['data'];

      return PostModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Cập nhật bài viết thất bại',
      );
    }
  }

  Future<PostModel> getPostDetail({
    required String token,
    required String postId,
  }) async {
    try {
      final response = await dio.get(
        '/post/$postId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final data = response.data['data'];

      return PostModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Không lấy được chi tiết bài viết',
      );
    }
  }
}
