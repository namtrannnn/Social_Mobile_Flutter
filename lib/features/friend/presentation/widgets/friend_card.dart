import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/controllers/friend_controller.dart';
import '../../data/models/friend_user_model.dart';

class FriendCard extends StatelessWidget {
  final FriendUserModel user;
  final String type;

  const FriendCard({super.key, required this.user, required this.type});

  @override
  Widget build(BuildContext context) {
    final controller = context.read<FriendController>();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: user.avatar.isNotEmpty
                ? NetworkImage(user.avatar)
                : null,
            child: user.avatar.isEmpty ? const Icon(Icons.person) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              user.fullName,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),

          if (type == 'suggestion')
            ElevatedButton(
              onPressed: () => controller.addFriend(user.id),
              child: const Text('Thêm bạn'),
            ),

          if (type == 'accept') ...[
            ElevatedButton(
              onPressed: () => controller.acceptFriend(user.id),
              child: const Text('Xác nhận'),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () => controller.refuseFriend(user.id),
              child: const Text('Từ chối'),
            ),
          ],

          if (type == 'list')
            const Text('Bạn bè', style: TextStyle(color: Colors.green)),
        ],
      ),
    );
  }
}
