import 'package:flutter/material.dart';

class ProfileFriendsSection extends StatelessWidget {
  const ProfileFriendsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final friends = [
      {'name': 'Nam', 'avatar': 'https://i.pravatar.cc/150?img=1'},
      {'name': 'Hoài', 'avatar': 'https://i.pravatar.cc/150?img=2'},
      {'name': 'Minh', 'avatar': 'https://i.pravatar.cc/150?img=3'},
      {'name': 'An', 'avatar': 'https://i.pravatar.cc/150?img=4'},
      {'name': 'Huy', 'avatar': 'https://i.pravatar.cc/150?img=5'},
    ];

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
                  onTap: () {},
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
                        backgroundImage: NetworkImage(friend['avatar']!),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        friend['name']!,
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
