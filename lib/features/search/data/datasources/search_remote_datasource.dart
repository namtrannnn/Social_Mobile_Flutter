import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../models/search_user_model.dart';

class SearchRemoteDataSource {
  final Dio dio = DioClient().dio;

  SearchRemoteDataSource();

  Future<List<SearchUserModel>> searchUsers({
    required String token,
    required String keyword,
  }) async {
    final res = await dio.get(
      '/user/search',
      queryParameters: {'q': keyword},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    final List data = res.data['data'] ?? [];

    return data.map((e) => SearchUserModel.fromJson(e)).toList();
  }
}
