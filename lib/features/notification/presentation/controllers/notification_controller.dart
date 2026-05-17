import 'package:flutter/material.dart';

import '../../../../core/storage/secure_storage_service.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/notification_repository.dart';

class NotificationController extends ChangeNotifier {
  final NotificationRepository repository;

  NotificationController({required this.repository});

  bool isLoading = false;

  int unreadCount = 0;

  List<NotificationModel> notifications = [];

  Future<void> loadNotifications() async {
    try {
      isLoading = true;
      notifyListeners();

      final token = await SecureStorageService.getValidToken();

      if (token == null) return;

      final result = await repository.getNotifications(token);

      unreadCount = result.unreadCount;

      notifications = result.notifications;
    } catch (e) {
      debugPrint('loadNotifications error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      final token = await SecureStorageService.getValidToken();

      if (token == null) return;

      await repository.markAsRead(token: token, notificationId: notificationId);

      final index = notifications.indexWhere(
        (item) => item.id == notificationId,
      );

      if (index == -1) return;

      if (!notifications[index].isRead) {
        unreadCount--;

        notifications[index] = NotificationModel(
          id: notifications[index].id,
          sender: notifications[index].sender,
          type: notifications[index].type,
          title: notifications[index].title,
          message: notifications[index].message,
          refId: notifications[index].refId,
          refType: notifications[index].refType,
          isRead: true,
          createdAt: notifications[index].createdAt,
        );

        notifyListeners();
      }
    } catch (e) {
      debugPrint('markAsRead error: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final token = await SecureStorageService.getValidToken();

      if (token == null) return;

      await repository.markAllAsRead(token);

      unreadCount = 0;

      notifications = notifications.map((item) {
        return NotificationModel(
          id: item.id,
          sender: item.sender,
          type: item.type,
          title: item.title,
          message: item.message,
          refId: item.refId,
          refType: item.refType,
          isRead: true,
          createdAt: item.createdAt,
        );
      }).toList();

      notifyListeners();
    } catch (e) {
      debugPrint('markAllAsRead error: $e');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      final token = await SecureStorageService.getValidToken();

      if (token == null) return;

      final notification = notifications.firstWhere(
        (item) => item.id == notificationId,
      );

      await repository.deleteNotification(
        token: token,
        notificationId: notificationId,
      );

      if (!notification.isRead && unreadCount > 0) {
        unreadCount--;
      }

      notifications.removeWhere((item) => item.id == notificationId);

      notifyListeners();
    } catch (e) {
      debugPrint('deleteNotification error: $e');
    }
  }

  void addRealtimeNotification(NotificationModel notification) {
    final exists = notifications.any((item) => item.id == notification.id);

    if (exists) return;

    notifications.insert(0, notification);

    if (!notification.isRead) {
      unreadCount++;
    }

    notifyListeners();
  }
}
