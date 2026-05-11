import 'package:flutter/material.dart';
import 'notification_tile.dart';

class NotificationSheet extends StatelessWidget {
  const NotificationSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text(
            "Thông báo",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 18),
          NotificationTile(text: "Nam đã thích bài viết của bạn"),
          NotificationTile(text: "Sang đã bình luận bài viết"),
          NotificationTile(text: "Lan bắt đầu theo dõi bạn"),
        ],
      ),
    );
  }
}
