import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/friend_controller.dart';

class FriendListScreen extends StatefulWidget {
  final String? userId;
  final String title;

  const FriendListScreen({super.key, this.userId, this.title = 'Bạn bè'});

  @override
  State<FriendListScreen> createState() => _FriendListScreenState();
}

class _FriendListScreenState extends State<FriendListScreen> {
  static const Color primaryColor = Color(0xFFF25019);
  static const Color backgroundColor = Color(0xFFF8F8F8);
  static const Color textColor = Color(0xFF1A1A1A);

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<FriendController>().loadFriends(userId: widget.userId);
    });
  }

  Future<void> _refresh() async {
    await context.read<FriendController>().loadFriends(userId: widget.userId);
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

      if (segments.length < 6) return rawUrl;

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
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: textColor,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Builder(
        builder: (_) {
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
              subtitle:
                  'Khi bạn kết bạn với người khác, danh sách sẽ hiện ở đây.',
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            color: primaryColor,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
              itemCount: controller.friends.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final friend = controller.friends[index];
                final avatarUrl = _normalizeCloudinaryUrl(friend.avatar);

                return Container(
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
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        // Mốt gắn qua profile người đó
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (_) => ProfileScreen(userId: friend.id),
                        //   ),
                        // );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            _FriendAvatar(avatarUrl: avatarUrl),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          friend.fullName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800,
                                            color: textColor,
                                          ),
                                        ),
                                      ),
                                      if (friend.isVerified) ...[
                                        const SizedBox(width: 5),
                                        const Icon(
                                          Icons.verified_rounded,
                                          color: Colors.blue,
                                          size: 17,
                                        ),
                                      ],
                                    ],
                                  ),

                                  const SizedBox(height: 5),

                                  Text(
                                    friend.username != null &&
                                            friend.username!.isNotEmpty
                                        ? '@${friend.username}'
                                        : 'Chưa có username',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 8),

                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: primaryColor,
                                size: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
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
      width: 58,
      height: 58,
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
      child: CircleAvatar(
        backgroundColor: const Color(0xFFEFEFEF),
        child: ClipOval(
          child: hasAvatar
              ? Image.network(
                  avatarUrl!,
                  width: 54,
                  height: 54,
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
