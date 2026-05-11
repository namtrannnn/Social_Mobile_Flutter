import 'package:dio/dio.dart';

import '../../../../app/config/api_config.dart';
import '../models/simple_user_model.dart';

class UserRemoteDataSource {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );

  Future<List<SimpleUserModel>> searchUsers({
    required String token,
    required String keyword,
  }) async {
    try {
      final response = await dio.get(
        '/user/search',
        queryParameters: {'q': keyword},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final List data = response.data['data'] ?? [];

      return data.map((e) => SimpleUserModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Tìm kiếm người dùng thất bại',
      );
    }
  }
}
