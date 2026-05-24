import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/post_model.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../controllers/post_controller.dart';
import 'liked_users_bottom_sheet.dart';
import 'comment_bottom_sheet.dart';
import '../../../auth/data/controllers/auth_controller.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../screens/edit_post_screen.dart';

class PostCard extends StatefulWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _showHeart = false;
  late int localCommentsCount;
  late bool localIsLiked;
  late int localLikesCount;

  @override
  void initState() {
    super.initState();
    localCommentsCount = widget.post.commentsCount;
    localIsLiked = widget.post.isLiked;
    localLikesCount = widget.post.likesCount;
  }

  Future<void> _handleDoubleTapLike(PostModel post) async {
    if (!localIsLiked) {
      final token = await SecureStorageService.getValidToken();

      if (token != null && mounted) {
        setState(() {
          localIsLiked = true;
          localLikesCount += 1;
        });

        context.read<PostController>().toggleLike(
          token: token,
          postId: post.id,
        );
      }
    }

    setState(() {
      _showHeart = true;
    });

    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    setState(() {
      _showHeart = false;
    });
  }

  Future<void> _handleLikeButton(PostModel post) async {
    final token = await SecureStorageService.getValidToken();
    if (token == null || !mounted) return;

    setState(() {
      localIsLiked = !localIsLiked;
      localLikesCount += localIsLiked ? 1 : -1;

      if (localLikesCount < 0) {
        localLikesCount = 0;
      }
    });

    context.read<PostController>().toggleLike(token: token, postId: post.id);
  }

  void _openLikedUsers(PostModel post) {
    if (localLikesCount <= 0) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return LikedUsersBottomSheet(postId: post.id);
      },
    );
  }

  void _openAuthorProfile(PostModel post) {
    if (post.authorId.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProfileScreen(userId: post.authorId)),
    );
  }

  void _openPostOptions(PostModel post) async {
    final auth = context.read<AuthController>();
    final currentUserId =
        auth.currentUser?.id ?? await SecureStorageService.getUserId() ?? '';

    if (!mounted) return;

    final bool isOwner = currentUserId == post.authorId;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),

                if (isOwner) ...[
                  ListTile(
                    leading: const Icon(Icons.edit_outlined),
                    title: const Text(
                      'Sửa bài viết',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    onTap: () async {
                      Navigator.pop(context);

                      final updated = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditPostScreen(post: post),
                        ),
                      );

                      if (!mounted) return;

                      if (updated == true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Bài viết đã được cập nhật'),
                          ),
                        );
                      }
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.lock_outline),
                    title: const Text(
                      'Quyền riêng tư',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text('Sửa ai có thể xem bài viết'),
                    onTap: () async {
                      Navigator.pop(context);

                      await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditPostScreen(post: post),
                        ),
                      );
                    },
                  ),

                  ListTile(
                    leading: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                    ),
                    title: const Text(
                      'Xóa bài viết',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Phần xóa bài viết mình sẽ làm tiếp sau',
                          ),
                        ),
                      );
                    },
                  ),
                ] else ...[
                  ListTile(
                    leading: const Icon(Icons.report_outlined),
                    title: const Text('Báo cáo bài viết'),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  List<TextSpan> _buildCaptionSpans(String caption) {
    final regex = RegExp(r'(@[a-zA-Z0-9_\.]+)');

    final spans = <TextSpan>[];
    int start = 0;

    for (final match in regex.allMatches(caption)) {
      if (match.start > start) {
        spans.add(
          TextSpan(
            text: caption.substring(start, match.start),
            style: const TextStyle(color: Colors.black),
          ),
        );
      }

      spans.add(
        TextSpan(
          text: match.group(0),
          style: const TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

      start = match.end;
    }

    if (start < caption.length) {
      spans.add(
        TextSpan(
          text: caption.substring(start),
          style: const TextStyle(color: Colors.black),
        ),
      );
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final imageUrl = post.media.isNotEmpty ? post.media.first.url : '';
    final bool validAuthorAvatar =
        post.authorAvatar.isNotEmpty &&
        post.authorAvatar.startsWith('https://res.cloudinary.com');
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _openAuthorProfile(post),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFFF1F1F1),
                    backgroundImage: validAuthorAvatar
                        ? NetworkImage(post.authorAvatar)
                        : null,
                    child: !validAuthorAvatar
                        ? const Icon(Icons.person, size: 20, color: Colors.grey)
                        : null,
                  ),
                ),
                const SizedBox(width: 10),

                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _openAuthorProfile(post),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.authorName.isNotEmpty
                              ? post.authorName
                              : 'Người dùng',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        if (post.location.isNotEmpty)
                          Text(
                            post.location,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                GestureDetector(
                  onTap: () => _openPostOptions(post),
                  child: const Icon(Icons.more_horiz, size: 24),
                ),
              ],
            ),
          ),

          // IMAGE + DOUBLE TAP HEART ANIMATION
          if (imageUrl.isNotEmpty)
            GestureDetector(
              onDoubleTap: () => _handleDoubleTapLike(post),
              child: AspectRatio(
                aspectRatio: 1,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.network(
                      imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),

                    AnimatedOpacity(
                      opacity: _showHeart ? 1 : 0,
                      duration: const Duration(milliseconds: 180),
                      child: AnimatedScale(
                        scale: _showHeart ? 1.25 : 0.6,
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOutBack,
                        child: const Icon(
                          Icons.favorite,
                          color: const Color(0xFFFF3040),
                          size: 105,
                          shadows: [
                            Shadow(
                              color: Colors.black45,
                              blurRadius: 14,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ACTIONS
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => _handleLikeButton(post),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    localIsLiked ? Icons.favorite : Icons.favorite_border,
                    color: localIsLiked ? Colors.red : Colors.black,
                    size: 28,
                  ),
                ),

                const SizedBox(width: 8),

                if (!post.hideLikeCount)
                  GestureDetector(
                    onTap: () => _openLikedUsers(post),
                    child: Text(
                      '$localLikesCount',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),

                const SizedBox(width: 18),

                GestureDetector(
                  onTap: () async {
                    final auth = context.read<AuthController>();
                    final currentUserId =
                        auth.currentUser?.id ??
                        await SecureStorageService.getUserId() ??
                        '';

                    if (!context.mounted) return;

                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) {
                        return CommentBottomSheet(
                          postId: post.id,
                          currentUserId: currentUserId,
                          postOwnerId: post.authorId,
                          initialAllowComments: post.allowComments,
                          onCommentCountChanged: (value) {
                            setState(() {
                              localCommentsCount += value;

                              if (localCommentsCount < 0) {
                                localCommentsCount = 0;
                              }
                            });
                          },
                        );
                      },
                    );
                  },
                  child: const Icon(Icons.chat_bubble_outline, size: 26),
                ),

                const SizedBox(width: 5),

                Text(
                  '$localCommentsCount',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(width: 18),

                const Icon(Icons.send_outlined, size: 27),
                const SizedBox(width: 5),
                Text(
                  '${post.sharesCount}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const Spacer(),

                const Icon(Icons.bookmark_border, size: 28),
              ],
            ),
          ),

          // CAPTION
          if (post.caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    height: 1.35,
                  ),
                  children: _buildCaptionSpans(post.caption),
                ),
              ),
            ),

          // TIME
          const Padding(
            padding: EdgeInsets.fromLTRB(12, 6, 12, 12),
            child: Text(
              'Vừa xong',
              style: TextStyle(color: Colors.black45, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}
