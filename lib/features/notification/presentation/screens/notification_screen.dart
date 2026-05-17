import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/notification_controller.dart';
import '../../data/models/notification_model.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<NotificationController>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationController>(
      builder: (context, controller, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: Text(
              'Thông báo ${controller.unreadCount > 0 ? "(${controller.unreadCount})" : ""}',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w800,
              ),
            ),
            actions: [
              if (controller.unreadCount > 0)
                TextButton(
                  onPressed: controller.markAllAsRead,
                  child: const Text(
                    'Đọc hết',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          body: controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : controller.notifications.isEmpty
              ? const Center(
                  child: Text(
                    'Chưa có thông báo nào',
                    style: TextStyle(color: Colors.black54),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: controller.loadNotifications,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: controller.notifications.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final notification = controller.notifications[index];

                      return Dismissible(
                        key: ValueKey(notification.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: Colors.red,
                          child: const Icon(
                            Icons.delete_outline,
                            color: Colors.white,
                          ),
                        ),
                        onDismissed: (_) {
                          controller.deleteNotification(notification.id);
                        },
                        child: NotificationTile(
                          notification: notification,
                          onTap: () {
                            controller.markAsRead(notification.id);
                          },
                        ),
                      );
                    },
                  ),
                ),
        );
      },
    );
  }
}

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final sender = notification.sender;

    return InkWell(
      onTap: onTap,
      child: Container(
        color: notification.isRead ? Colors.white : const Color(0xFFFFF3ED),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: sender.avatar.isNotEmpty
                  ? NetworkImage(sender.avatar)
                  : null,
              child: sender.avatar.isEmpty
                  ? const Icon(Icons.person, color: Colors.grey)
                  : null,
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title.isNotEmpty
                        ? notification.title
                        : _titleFromType(notification.type),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: notification.isRead
                          ? FontWeight.w600
                          : FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatTime(notification.createdAt),
                    style: const TextStyle(fontSize: 12, color: Colors.black45),
                  ),
                ],
              ),
            ),

            if (!notification.isRead)
              Container(
                margin: const EdgeInsets.only(top: 6),
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                  color: Color(0xFFF25019),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  static String _titleFromType(String type) {
    switch (type) {
      case 'friend_request':
        return 'Lời mời kết bạn';
      case 'friend_accept':
        return 'Đã chấp nhận kết bạn';
      case 'post_like':
        return 'Lượt thích mới';
      case 'post_comment':
        return 'Bình luận mới';
      case 'comment_reply':
        return 'Phản hồi bình luận';
      case 'mention':
        return 'Bạn được nhắc đến';
      default:
        return 'Thông báo';
    }
  }

  static String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';

    return '${time.day}/${time.month}/${time.year}';
  }
}
