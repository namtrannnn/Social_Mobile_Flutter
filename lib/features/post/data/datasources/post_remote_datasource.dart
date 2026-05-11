import 'package:dio/dio.dart';
import 'dart:convert';
import '../../../../app/config/api_config.dart';
import '../models/post_model.dart';

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

      print('GET FEED STATUS: ${response.statusCode}');
      print('GET FEED DATA: ${response.data}');

      final data = response.data;

      final List list = data['data'] ?? [];
      final pagination = data['pagination'] ?? {};

      return FeedPostResult(
        posts: list.map((e) => PostModel.fromJson(e)).toList(),
        nextCursor: pagination['nextCursor'],
        hasMore: pagination['hasMore'] ?? false,
      );
    } on DioException catch (e) {
      print('GET FEED ERROR: ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? 'Lấy feed thất bại');
    }
  }

  // [POST createPost
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

      print('CREATE POST STATUS: ${response.statusCode}');
      print('CREATE POST DATA: ${response.data}');

      final data = response.data['data'];

      return PostModel.fromJson(data);
    } on DioException catch (e) {
      print('CREATE POST ERROR: ${e.response?.data}');

      throw Exception(e.response?.data['message'] ?? 'Tạo bài viết thất bại');
    }
  }
}
