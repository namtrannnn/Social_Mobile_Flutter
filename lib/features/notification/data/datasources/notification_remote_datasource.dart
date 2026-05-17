import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../models/notification_model.dart';

class NotificationRemoteDataSource {
  final Dio _dio = DioClient().dio;

  Future<NotificationResult> getNotifications(String token) async {
    try {
      final response = await _dio.get(
        '/notifications',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final data = response.data;

      if (response.statusCode == 200 && data['code'] == 200) {
        final notifications = (data['notifications'] as List)
            .map((item) => NotificationModel.fromJson(item))
            .toList();

        return NotificationResult(
          unreadCount: data['unreadCount'] ?? 0,
          notifications: notifications,
        );
      }

      throw Exception(data['message'] ?? 'Không tải được thông báo');
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ?? 'Không tải được thông báo';
      throw Exception(message);
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> markAsRead({
    required String token,
    required String notificationId,
  }) async {
    try {
      final response = await _dio.patch(
        '/notifications/read/$notificationId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final data = response.data;

      if (response.statusCode != 200 || data['code'] != 200) {
        throw Exception(data['message'] ?? 'Không thể đánh dấu đã đọc');
      }
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ?? 'Không thể đánh dấu đã đọc';
      throw Exception(message);
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> markAllAsRead(String token) async {
    try {
      final response = await _dio.patch(
        '/notifications/read-all',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final data = response.data;

      if (response.statusCode != 200 || data['code'] != 200) {
        throw Exception(data['message'] ?? 'Không thể đánh dấu tất cả đã đọc');
      }
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ?? 'Không thể đánh dấu tất cả đã đọc';
      throw Exception(message);
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> deleteNotification({
    required String token,
    required String notificationId,
  }) async {
    try {
      final response = await _dio.delete(
        '/notifications/$notificationId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final data = response.data;

      if (response.statusCode != 200 || data['code'] != 200) {
        throw Exception(data['message'] ?? 'Không thể xóa thông báo');
      }
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Không thể xóa thông báo';
      throw Exception(message);
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}

class NotificationResult {
  final int unreadCount;
  final List<NotificationModel> notifications;

  NotificationResult({required this.unreadCount, required this.notifications});
}
