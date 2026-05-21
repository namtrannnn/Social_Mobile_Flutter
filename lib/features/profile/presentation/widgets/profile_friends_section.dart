import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/profile_model.dart';
import '../../../friend/presentation/controllers/friend_controller.dart';
import '../../../friend/presentation/screens/friend_list_screen.dart';

class ProfileFriendsSection extends StatefulWidget {
  final ProfileModel profile;

  const ProfileFriendsSection({super.key, required this.profile});

  @override
  State<ProfileFriendsSection> createState() => _ProfileFriendsSectionState();
}

class _ProfileFriendsSectionState extends State<ProfileFriendsSection> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<FriendController>().loadFriends(
        userId: widget.profile.user.id,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final friendController = context.watch<FriendController>();
    final friends = friendController.friends.take(10).toList();

    if (friendController.isLoadingFriends) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (friends.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 0, 8),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                const Text(
                  'Bạn bè',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FriendListScreen(
                          userId: widget.profile.user.id,
                          title: 'Bạn bè',
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Xem tất cả',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          SizedBox(
            height: 82,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: friends.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final friend = friends[index];

                return SizedBox(
                  width: 64,
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage:
                            friend.avatar != null && friend.avatar!.isNotEmpty
                            ? NetworkImage(friend.avatar!)
                            : null,
                        child: friend.avatar == null || friend.avatar!.isEmpty
                            ? const Icon(Icons.person, color: Colors.grey)
                            : null,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        friend.fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
