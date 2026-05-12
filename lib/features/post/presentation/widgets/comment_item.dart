import 'package:flutter/material.dart';
import '../../data/models/comment_model.dart';
import 'package:provider/provider.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../controllers/comment_controller.dart';

class CommentItem extends StatelessWidget {
  final CommentModel comment;
  final Function(CommentModel comment)? onReplyComment;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isReply;
  final Function(CommentModel comment)? onLongPressComment;
  final Function(CommentModel comment)? onViewReplies;
  const CommentItem({
    super.key,
    required this.comment,
    this.onReplyComment,
    this.onEdit,
    this.onDelete,
    this.isReply = false,
    this.onLongPressComment,
    this.onViewReplies,
  });
  List<TextSpan> _buildContentSpans(String content) {
    final regex = RegExp(r'(@[a-zA-Z0-9_.]+)');
    final matches = regex.allMatches(content);

    if (matches.isEmpty) {
      return [
        TextSpan(
          text: content,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14.5,
            height: 1.25,
          ),
        ),
      ];
    }

    List<TextSpan> spans = [];

    int current = 0;

    for (final match in matches) {
      if (match.start > current) {
        spans.add(
          TextSpan(
            text: content.substring(current, match.start),
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14.5,
              height: 1.25,
            ),
          ),
        );
      }

      spans.add(
        TextSpan(
          text: match.group(0),
          style: const TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.w700,
            fontSize: 14.5,
            height: 1.25,
          ),
        ),
      );

      current = match.end;
    }

    if (current < content.length) {
      spans.add(
        TextSpan(
          text: content.substring(current),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14.5,
            height: 1.25,
          ),
        ),
      );
    }

    return spans;
  }

  Widget _defaultAvatar(bool isReply) {
    return Container(
      color: Colors.grey.shade200,
      child: Icon(
        Icons.person,
        color: Colors.grey.shade500,
        size: isReply ? 15 : 19,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final avatarUrl = comment.user.avatar;

    final bool validAvatar =
        avatarUrl.isNotEmpty &&
        avatarUrl.startsWith('https://res.cloudinary.com');

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: () => onLongPressComment?.call(comment),
      child: Padding(
        padding: EdgeInsets.only(
          left: 0,
          right: isReply ? 0 : 12,
          top: isReply ? 6 : 12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: isReply ? 42 : 0),
                  child: SizedBox(
                    width: isReply ? 28 : 36,
                    height: isReply ? 28 : 36,
                    child: ClipOval(
                      child: validAvatar
                          ? Image.network(
                              avatarUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _defaultAvatar(isReply),
                            )
                          : _defaultAvatar(isReply),
                    ),
                  ),
                ),

                const SizedBox(width: 9),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 4,
                        children: [
                          Text(
                            comment.user.username.isNotEmpty
                                ? comment.user.username
                                : comment.user.fullName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13.2,
                            ),
                          ),
                          Text(
                            _timeAgo(comment.createdAt),
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          ),
                          if (comment.isLikedByPostAuthor) ...[
                            Text(
                              '·',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                              ),
                            ),
                            const Icon(
                              Icons.favorite,
                              size: 12,
                              color: Colors.red,
                            ),
                            Text(
                              'tác giả',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),

                      if (comment.isPinned && !isReply)
                        Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Row(
                            children: [
                              Icon(
                                Icons.push_pin,
                                size: 12,
                                color: Colors.orange.shade700,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Bình luận được ghim',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (comment.status == 'hidden')
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'Đã ẩn',
                              style: TextStyle(
                                color: Colors.orange.shade800,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 3),

                      RichText(
                        text: TextSpan(
                          children: _buildContentSpans(comment.content),
                        ),
                      ),

                      const SizedBox(height: 5),

                      Row(
                        children: [
                          if (onReplyComment != null)
                            GestureDetector(
                              onTap: () => onReplyComment?.call(comment),
                              child: Text(
                                'Trả lời',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          if (comment.isEdited) ...[
                            const SizedBox(width: 8),
                            Text(
                              'Đã chỉnh sửa',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  width: 32,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: GestureDetector(
                      onTap: () async {
                        final token =
                            await SecureStorageService.getValidToken();
                        if (token == null) return;
                        if (!context.mounted) return;

                        context.read<CommentController>().toggleLikeComment(
                          token: token,
                          commentId: comment.id,
                        );
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            comment.isLiked
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 17,
                            color: comment.isLiked
                                ? Colors.red
                                : Colors.grey.shade600,
                          ),
                          if (comment.likesCount > 0)
                            Text(
                              '${comment.likesCount}',
                              style: TextStyle(
                                fontSize: 10.5,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            if (!isReply && comment.repliesCount > 0) ...[
              const SizedBox(height: 8),
              if (comment.replies.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 45),
                  child: GestureDetector(
                    onTap: () => onViewReplies?.call(comment),
                    child: Text(
                      '── Xem ${comment.repliesCount} phản hồi',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

              if (comment.replies.isNotEmpty)
                ...comment.replies.map(
                  (reply) => CommentItem(
                    comment: reply,
                    isReply: true,
                    onReplyComment: onReplyComment,
                    onEdit: onEdit,
                    onDelete: onDelete,
                    onLongPressComment: onLongPressComment,
                    onViewReplies: onViewReplies,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);

    if (diff.inSeconds < 60) return 'vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút';
    if (diff.inHours < 24) return '${diff.inHours} giờ';
    if (diff.inDays < 7) return '${diff.inDays} ngày';

    return '${time.day}/${time.month}/${time.year}';
  }
}
