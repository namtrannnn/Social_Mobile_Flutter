import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/controllers/friend_controller.dart';

class RequestFriendsSheet extends StatelessWidget {
  const RequestFriendsSheet();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FriendController>();

    return SizedBox(
      height: 420,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Lời mời đã gửi',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: controller.requestFriends.isEmpty
                  ? const Center(
                      child: Text('Lời mời kết bạn của bạn sẽ hiển thị ở đây.'),
                    )
                  : ListView.builder(
                      itemCount: controller.requestFriends.length,
                      itemBuilder: (context, index) {
                        final user = controller.requestFriends[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: user.avatar.isNotEmpty
                                ? NetworkImage(user.avatar)
                                : null,
                            child: user.avatar.isEmpty
                                ? const Icon(Icons.person)
                                : null,
                          ),
                          title: Text(user.fullName),
                          trailing: TextButton(
                            onPressed: () {
                              controller.cancelFriend(user.id);
                            },
                            child: const Text('Hủy lời mời'),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
