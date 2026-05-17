import 'package:flutter/material.dart';

import '../../data/models/profile_post_grid_model.dart';
import '../screens/user_posts_screen.dart';

class ProfilePostGrid extends StatelessWidget {
  final String userId;
  final List<ProfileGridPostModel> posts;

  const ProfilePostGrid({super.key, required this.userId, required this.posts});

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 160),
          Center(
            child: Text(
              'Chưa có bài viết',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      );
    }
    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 2),
      itemCount: posts.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemBuilder: (context, index) {
        final post = posts[index];
        final media = post.firstMedia;

        if (media == null || media.url.isEmpty) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      UserPostsScreen(userId: userId, initialIndex: index),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFF8FAFC), Color(0xFFEFF6FF)],
                ),
                border: Border.all(color: Color(0xFFE5E7EB), width: 0.6),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -8,
                    left: -2,
                    child: Text(
                      '“',
                      style: TextStyle(
                        fontSize: 42,
                        height: 1,
                        fontWeight: FontWeight.w800,
                        color: Colors.black.withOpacity(0.08),
                      ),
                    ),
                  ),

                  Center(
                    child: Text(
                      post.caption.trim().isNotEmpty
                          ? post.caption.trim()
                          : 'Bài viết',
                      textAlign: TextAlign.center,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),

                  const Positioned(
                    right: 0,
                    bottom: 0,
                    child: Icon(
                      Icons.notes_rounded,
                      size: 16,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final imageUrl = media.type == 'video' && media.thumbnail.isNotEmpty
            ? media.thumbnail
            : media.url;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    UserPostsScreen(userId: userId, initialIndex: index),
              ),
            );
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return Container(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.broken_image_outlined),
                  );
                },
              ),

              if (post.mediaCount > 1)
                const Positioned(
                  top: 6,
                  right: 6,
                  child: Icon(Icons.collections, color: Colors.white, size: 18),
                ),

              if (media.type == 'video')
                const Positioned(
                  top: 6,
                  right: 6,
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
