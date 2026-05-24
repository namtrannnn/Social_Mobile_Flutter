import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../controllers/friend_controller.dart';

class FriendCenterScreen extends StatefulWidget {
  const FriendCenterScreen({super.key});

  @override
  State<FriendCenterScreen> createState() => _FriendCenterScreenState();
}

class _FriendCenterScreenState extends State<FriendCenterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const Color primaryColor = Color(0xFFF25019);
  static const Color backgroundColor = Color(0xFFF8F8F8);
  static const Color textColor = Color(0xFF1A1A1A);

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() {
      final controller = context.read<FriendController>();

      controller.loadReceivedRequests();
      controller.loadFriends();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openProfile(String userId) {
    if (userId.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProfileScreen(userId: userId)),
    );
  }

  Future<void> _refresh() async {
    final controller = context.read<FriendController>();

    await Future.wait([
      controller.loadReceivedRequests(),
      controller.loadFriends(),
    ]);
  }

  String? _normalizeCloudinaryUrl(String? url) {
    if (url == null || url.trim().isEmpty) return null;

    final rawUrl = url.trim();

    if (!rawUrl.startsWith('http')) return null;

    if (!rawUrl.contains('res-console.cloudinary.com')) {
      return rawUrl;
    }

    try {
      final uri = Uri.parse(rawUrl);
      final segments = uri.pathSegments;

      if (segments.isEmpty) return rawUrl;

      final cloudName = segments[0];

      final uploadIndex = segments.indexOf('upload');

      if (uploadIndex == -1 || uploadIndex + 1 >= segments.length) {
        return rawUrl;
      }

      final encodedPublicId = segments[uploadIndex + 1];

      final normalizedBase64 = base64Url.normalize(encodedPublicId);
      final decodedPath = utf8.decode(base64Url.decode(normalizedBase64));

      return 'https://res.cloudinary.com/$cloudName/image/upload/$decodedPath';
    } catch (_) {
      return rawUrl;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FriendController>();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
        ),
        title: const Text(
          'Bạn bè',
          style: TextStyle(color: textColor, fontWeight: FontWeight.w900),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: primaryColor,
          unselectedLabelColor: Colors.black54,
          indicatorColor: primaryColor,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: 'Lời mời'),
            Tab(text: 'Bạn bè'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildRequestTab(controller), _buildFriendTab(controller)],
      ),
    );
  }

  Widget _buildRequestTab(FriendController controller) {
    if (controller.isLoadingRequests) {
      return const Center(
        child: CircularProgressIndicator(color: primaryColor),
      );
    }

    if (controller.errorMessage != null) {
      return _buildEmptyState(
        icon: Icons.error_outline_rounded,
        title: 'Có lỗi xảy ra',
        subtitle: controller.errorMessage!,
        iconColor: Colors.redAccent,
      );
    }

    if (controller.receivedRequests.isEmpty) {
      return _buildEmptyState(
        icon: Icons.person_add_alt_1_rounded,
        title: 'Chưa có lời mời',
        subtitle: 'Khi có người gửi lời mời kết bạn, họ sẽ xuất hiện ở đây.',
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      color: primaryColor,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
        itemCount: controller.receivedRequests.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final user = controller.receivedRequests[index];
          final avatarUrl = _normalizeCloudinaryUrl(user.avatar);

          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.045),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _openProfile(user.id),
                  child: Row(
                    children: [
                      _FriendAvatar(avatarUrl: avatarUrl),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.fullName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.username == null || user.username!.isEmpty
                                  ? 'Chưa có username'
                                  : '@${user.username}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 38,
                        child: ElevatedButton(
                          onPressed: controller.isLoading
                              ? null
                              : () async {
                                  await controller.acceptRequest(user.id);

                                  if (!context.mounted) return;

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Đã chấp nhận lời mời kết bạn',
                                      ),
                                    ),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1877F2),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Chấp nhận',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: SizedBox(
                        height: 38,
                        child: OutlinedButton(
                          onPressed: controller.isLoading
                              ? null
                              : () async {
                                  await controller.refuseRequest(user.id);

                                  if (!context.mounted) return;

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Đã từ chối lời mời'),
                                    ),
                                  );
                                },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black,
                            side: const BorderSide(color: Color(0xFFE5E7EB)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Từ chối',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFriendTab(FriendController controller) {
    if (controller.isLoadingFriends) {
      return const Center(
        child: CircularProgressIndicator(color: primaryColor),
      );
    }

    if (controller.errorMessage != null) {
      return _buildEmptyState(
        icon: Icons.error_outline_rounded,
        title: 'Có lỗi xảy ra',
        subtitle: controller.errorMessage!,
        iconColor: Colors.redAccent,
      );
    }

    if (controller.friends.isEmpty) {
      return _buildEmptyState(
        icon: Icons.group_outlined,
        title: 'Chưa có bạn bè',
        subtitle: 'Khi bạn chấp nhận lời mời kết bạn, danh sách sẽ hiện ở đây.',
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      color: primaryColor,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
        itemCount: controller.friends.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final friend = controller.friends[index];

          final avatarUrl = _normalizeCloudinaryUrl(friend.avatar);

          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.045),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _openProfile(friend.id),
                  child: _FriendAvatar(avatarUrl: avatarUrl),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _openProfile(friend.id),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          friend.fullName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          friend.username == null || friend.username!.isEmpty
                              ? 'Chưa có username'
                              : '@${friend.username}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                SizedBox(
                  height: 36,
                  child: OutlinedButton(
                    onPressed: () {
                      // lát nữa nối sang ChatScreen
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Nhắn tin',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    Color iconColor = primaryColor,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 34),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 42, color: iconColor),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.45,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FriendAvatar extends StatelessWidget {
  final String? avatarUrl;

  const _FriendAvatar({required this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    final hasAvatar = avatarUrl != null && avatarUrl!.isNotEmpty;

    return Container(
      width: 56,
      height: 56,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            const Color(0xFFF25019).withOpacity(0.9),
            const Color(0xFFF25019).withOpacity(0.25),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ClipOval(
        child: Container(
          color: const Color(0xFFEFEFEF),
          child: hasAvatar
              ? Image.network(
                  avatarUrl!,
                  width: 52,
                  height: 52,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.person_rounded,
                      color: Colors.grey,
                      size: 30,
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;

                    return const Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFF25019),
                        ),
                      ),
                    );
                  },
                )
              : const Icon(Icons.person_rounded, color: Colors.grey, size: 30),
        ),
      ),
    );
  }
}
