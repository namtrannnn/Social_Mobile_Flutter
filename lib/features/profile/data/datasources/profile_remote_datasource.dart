import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../models/profile_model.dart';
import '../models/profile_post_grid_model.dart';
import '../../../post/data/models/post_model.dart';

class ProfileRemoteDataSource {
  final Dio dio = DioClient().dio;

  ProfileRemoteDataSource();

  Future<ProfileModel> getMyProfile({required String token}) async {
    final res = await dio.get(
      '/profile/me',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return ProfileModel.fromJson(res.data['data']);
  }

  Future<ProfileModel> getUserProfile({
    required String token,
    required String userId,
  }) async {
    final res = await dio.get(
      '/profile/$userId',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return ProfileModel.fromJson(res.data['data']);
  }

  Future<List<ProfileGridPostModel>> getUserPostGrid({
    required String token,
    required String userId,
    int limit = 30,
    String? cursor,
  }) async {
    final res = await dio.get(
      '/profile/$userId/posts/grid',
      queryParameters: {'limit': limit, if (cursor != null) 'cursor': cursor},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    // print('===== PROFILE GRID RESPONSE =====');
    // print(res.data);

    final List data = res.data['data'] ?? [];

    return data.map((e) => ProfileGridPostModel.fromJson(e)).toList();
  }

  Future<List<PostModel>> getUserPostFeed({
    required String token,
    required String userId,
    int limit = 20,
    String? cursor,
  }) async {
    final res = await dio.get(
      '/profile/$userId/posts/feed',
      queryParameters: {'limit': limit, if (cursor != null) 'cursor': cursor},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    final List data = res.data['data'] ?? [];

    return data.map((e) => PostModel.fromJson(e)).toList();
  }

  Future<ProfileUserModel> updateProfile({
    required String token,
    required String fullName,
    required String username,
    required String bio,
    required bool isPrivate,
    String? avatarPath,
  }) async {
    final formData = FormData.fromMap({
      'fullName': fullName,
      'username': username,
      'bio': bio,
      'isPrivate': isPrivate.toString(),
      if (avatarPath != null)
        'avatar': await MultipartFile.fromFile(avatarPath),
    });

    final res = await dio.patch(
      '/profile/update',
      data: formData,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return ProfileUserModel.fromJson(res.data['data']);
  }
}
