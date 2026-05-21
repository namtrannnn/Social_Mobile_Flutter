import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../models/friend_model.dart';

class FriendRemoteDataSource {
  final Dio _dio = DioClient().dio;

  Future<Options> _authOptions() async {
    final token = await SecureStorageService.getValidToken();

    return Options(
      headers: {
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );
  }

  String _extractMessage(DioException error, String fallbackMessage) {
    final data = error.response?.data;

    if (data is Map<String, dynamic>) {
      return data['message']?.toString() ?? fallbackMessage;
    }

    return fallbackMessage;
  }

  Future<String> getRelationStatus(String userId) async {
    try {
      final response = await _dio.get(
        '/friends/status/$userId',
        options: await _authOptions(),
      );

      return response.data['relationStatus']?.toString() ?? 'none';
    } on DioException catch (e) {
      throw Exception(_extractMessage(e, 'Không lấy được trạng thái quan hệ'));
    }
  }

  Future<String> sendRequest(String userId) async {
    try {
      final response = await _dio.post(
        '/friends/request/$userId',
        options: await _authOptions(),
      );

      return response.data['data']?['relationStatus']?.toString() ??
          'pending_sent';
    } on DioException catch (e) {
      throw Exception(_extractMessage(e, 'Không gửi được lời mời kết bạn'));
    }
  }

  Future<String> cancelRequest(String userId) async {
    try {
      final response = await _dio.delete(
        '/friends/request/$userId',
        options: await _authOptions(),
      );

      return response.data['data']?['relationStatus']?.toString() ?? 'none';
    } on DioException catch (e) {
      throw Exception(_extractMessage(e, 'Không hủy được lời mời kết bạn'));
    }
  }

  Future<String> acceptRequest(String userId) async {
    try {
      final response = await _dio.post(
        '/friends/accept/$userId',
        options: await _authOptions(),
      );

      return response.data['data']?['relationStatus']?.toString() ?? 'friend';
    } on DioException catch (e) {
      throw Exception(
        _extractMessage(e, 'Không chấp nhận được lời mời kết bạn'),
      );
    }
  }

  Future<String> refuseRequest(String userId) async {
    try {
      final response = await _dio.delete(
        '/friends/refuse/$userId',
        options: await _authOptions(),
      );

      return response.data['data']?['relationStatus']?.toString() ?? 'none';
    } on DioException catch (e) {
      throw Exception(_extractMessage(e, 'Không từ chối được lời mời kết bạn'));
    }
  }

  Future<List<FriendModel>> getListFriends({String? userId}) async {
    try {
      final path = userId == null || userId.isEmpty
          ? '/friends/list'
          : '/friends/list/$userId';

      final response = await _dio.get(path, options: await _authOptions());

      final data = response.data['data'];
      final friends = data?['friends'];

      if (friends is! List) {
        return [];
      }

      return friends
          .map((item) => FriendModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(_extractMessage(e, 'Không lấy được danh sách bạn bè'));
    }
  }

  Future<List<FriendModel>> getReceivedRequests() async {
    try {
      final response = await _dio.get(
        '/friends/requests/received',
        options: await _authOptions(),
      );

      final data = response.data['data'];
      final requests = data?['requests'];

      if (requests is! List) {
        return [];
      }

      return requests
          .map((item) => FriendModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        _extractMessage(e, 'Không lấy được danh sách lời mời kết bạn'),
      );
    }
  }
}
