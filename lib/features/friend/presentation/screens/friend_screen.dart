import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/controllers/friend_controller.dart';
import '../widgets/friend_card.dart';
import '../widgets/friend_section.dart';

class FriendScreen extends StatefulWidget {
  const FriendScreen({super.key});

  @override
  State<FriendScreen> createState() => _FriendScreenState();
}

class _FriendScreenState extends State<FriendScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<FriendController>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FriendController>();

    if (controller.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (controller.errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Bạn bè'),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Center(child: Text(controller.errorMessage!)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F3F0),
      appBar: AppBar(
        title: const Text('Bạn bè'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: controller.loadAll,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Lời mời kết bạn (${controller.acceptFriends.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _showRequestFriends(context);
                  },
                  child: const Text('Đã gửi'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (controller.acceptFriends.isEmpty)
              const Text('Không có lời mời kết bạn')
            else
              ...controller.acceptFriends.map(
                (u) => FriendCard(user: u, type: 'accept'),
              ),

            const SizedBox(height: 24),

            Text(
              'Những người bạn có thể biết (${controller.suggestions.length})',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),

            if (controller.suggestions.isEmpty)
              const Text('Không có gợi ý bạn bè')
            else
              ...controller.suggestions.map(
                (u) => FriendCard(user: u, type: 'suggestion'),
              ),

            const SizedBox(height: 24),

            Text(
              'Danh sách bạn bè (${controller.listFriends.length})',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),

            if (controller.listFriends.isEmpty)
              const Text('Chưa có bạn bè')
            else
              ...controller.listFriends.map(
                (u) => FriendCard(user: u, type: 'list'),
              ),
          ],
        ),
      ),
    );
  }

  void _showRequestFriends(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const RequestFriendsSheet(),
    );
  }
}
