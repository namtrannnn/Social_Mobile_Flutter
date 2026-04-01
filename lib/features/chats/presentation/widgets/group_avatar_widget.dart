import 'package:flutter/material.dart';
import '../../data/models/chat_member.dart';

class GroupAvatarWidget extends StatelessWidget {
  final List<ChatMember> members;
  final String currentUserId;
  final double size;

  const GroupAvatarWidget({
    super.key,
    required this.members,
    required this.currentUserId,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final users = members
        .map((e) => e.user)
        .where((u) => u.id != currentUserId)
        .toList();

    final count = users.length;

    if (count <= 2) {
      return SizedBox(
        width: size + 12,
        height: size,
        child: Stack(
          clipBehavior: Clip.none,
          children: List.generate(
            count,
            (i) => Positioned(
              left: i * 18,
              child: CircleAvatar(
                radius: size / 2,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: size / 2 - 1.5,
                  backgroundImage: users[i].avatar != null
                      ? NetworkImage(users[i].avatar!)
                      : null,
                  child: users[i].avatar == null
                      ? Text(
                          users[i].fullName.isNotEmpty
                              ? users[i].fullName[0]
                              : '?',
                        )
                      : null,
                ),
              ),
            ),
          ),
        ),
      );
    }

    final showUsers = count >= 5
        ? users.take(3).toList()
        : users.take(4).toList();
    final remain = count - 3;

    Widget avatar(String? url, {String? label}) {
      return Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white),
          color: const Color(0xffe4e6eb),
        ),
        child: label != null
            ? Center(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : CircleAvatar(
                radius: 9,
                backgroundImage: url != null ? NetworkImage(url) : null,
              ),
      );
    }

    return SizedBox(
      width: 44,
      height: 44,
      child: GridView.count(
        crossAxisCount: 2,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        children: [
          avatar(showUsers[0].avatar),
          avatar(showUsers[1].avatar),
          avatar(showUsers[2].avatar),
          count == 4
              ? avatar(showUsers[3].avatar)
              : avatar(null, label: '+$remain'),
        ],
      ),
    );
  }
}
