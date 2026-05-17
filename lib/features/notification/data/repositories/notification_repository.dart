import '../datasources/notification_remote_datasource.dart';

class NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepository({required this.remoteDataSource});

  Future<NotificationResult> getNotifications(String token) {
    return remoteDataSource.getNotifications(token);
  }

  Future<void> markAsRead({
    required String token,
    required String notificationId,
  }) {
    return remoteDataSource.markAsRead(
      token: token,
      notificationId: notificationId,
    );
  }

  Future<void> markAllAsRead(String token) {
    return remoteDataSource.markAllAsRead(token);
  }

  Future<void> deleteNotification({
    required String token,
    required String notificationId,
  }) {
    return remoteDataSource.deleteNotification(
      token: token,
      notificationId: notificationId,
    );
  }
}
