import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/storage/secure_storage_service.dart';
import '../controllers/comment_controller.dart';
import 'comment_item.dart';
import '../../data/models/comment_model.dart';
import 'dart:async';

class CommentBottomSheet extends StatefulWidget {
  final String postId;
  final String currentUserId;
  final String postOwnerId;
  final bool initialAllowComments;

  final void Function(int value)? onCommentCountChanged;
  const CommentBottomSheet({
    super.key,
    required this.postId,
    required this.currentUserId,
    required this.postOwnerId,
    required this.initialAllowComments,
    this.onCommentCountChanged,
  });

  @override
  State<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _ActionRow extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool danger;
  final bool showDivider;

  const _ActionRow({
    required this.title,
    required this.icon,
    required this.onTap,
    this.danger = false,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger ? const Color(0xFFE53935) : Colors.black87;

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(icon, color: color, size: 23),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(height: 1, thickness: 0.6, color: Colors.grey.shade200),
      ],
    );
  }
}

class _SelectedCommentPreview extends StatelessWidget {
  final CommentModel comment;

  const _SelectedCommentPreview({required this.comment});

  @override
  Widget build(BuildContext context) {
    final avatarUrl = comment.user.avatar;
    final validAvatar =
        avatarUrl.isNotEmpty &&
        avatarUrl.startsWith('https://res.cloudinary.com');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 19,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: validAvatar ? NetworkImage(avatarUrl) : null,
            child: !validAvatar
                ? Icon(Icons.person, size: 20, color: Colors.grey.shade600)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: comment.user.username.isNotEmpty
                        ? comment.user.username
                        : comment.user.fullName,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  TextSpan(
                    text: '  ${comment.content}',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  String selectedSort = 'newest';
  bool allowComments = true;
  bool isUpdatingAllowComments = false;
  CommentModel? replyingComment;
  CommentModel? editingComment;

  @override
  void initState() {
    super.initState();
    allowComments = widget.initialAllowComments;
    Future.microtask(() async {
      final token = await SecureStorageService.getValidToken();
      if (token == null) return;

      context.read<CommentController>().loadComments(
        token: token,
        postId: widget.postId,
        refresh: true,
        sort: selectedSort,
      );
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _showCommentActions(CommentModel comment) {
    final bool isMyComment = comment.user.id == widget.currentUserId;
    final bool isPostOwner = widget.postOwnerId == widget.currentUserId;

    final bool canEdit = isMyComment;
    final bool canDelete = isMyComment || isPostOwner;
    final bool canPin = isPostOwner && comment.parentComment == null;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Comment actions',
      barrierColor: Colors.black.withOpacity(0.18),
      transitionDuration: const Duration(milliseconds: 160),
      pageBuilder: (_, __, ___) {
        return SafeArea(
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.pop(context),
              child: SizedBox.expand(
                child: Center(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SelectedCommentPreview(comment: comment),
                          const SizedBox(height: 14),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.12),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (allowComments)
                                  _ActionRow(
                                    title: 'Trả lời',
                                    icon: Icons.reply_rounded,
                                    onTap: () {
                                      Navigator.pop(context);
                                      _startReply(comment);
                                    },
                                  ),
                                if (canPin)
                                  _ActionRow(
                                    title: comment.isPinned
                                        ? 'Bỏ ghim bình luận'
                                        : 'Ghim bình luận',
                                    icon: comment.isPinned
                                        ? Icons.push_pin_outlined
                                        : Icons.push_pin,
                                    onTap: () async {
                                      Navigator.pop(context);

                                      final token =
                                          await SecureStorageService.getValidToken();
                                      if (token == null || !mounted) return;

                                      if (comment.isPinned) {
                                        await context
                                            .read<CommentController>()
                                            .unpinComment(
                                              token: token,
                                              commentId: comment.id,
                                            );
                                      } else {
                                        await context
                                            .read<CommentController>()
                                            .pinComment(
                                              token: token,
                                              commentId: comment.id,
                                            );
                                      }
                                    },
                                  ),

                                if (isPostOwner && !isMyComment)
                                  _ActionRow(
                                    title: comment.status == 'hidden'
                                        ? 'Hiện lại bình luận'
                                        : 'Ẩn bình luận',
                                    icon: comment.status == 'hidden'
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    onTap: () async {
                                      Navigator.pop(context);

                                      final token =
                                          await SecureStorageService.getValidToken();
                                      if (token == null || !mounted) return;

                                      if (comment.status == 'hidden') {
                                        await context
                                            .read<CommentController>()
                                            .unhideComment(
                                              token: token,
                                              commentId: comment.id,
                                            );
                                      } else {
                                        await context
                                            .read<CommentController>()
                                            .hideComment(
                                              token: token,
                                              commentId: comment.id,
                                            );
                                      }
                                    },
                                  ),
                                if (canEdit && allowComments)
                                  _ActionRow(
                                    title: 'Sửa bình luận',
                                    icon: Icons.edit_outlined,
                                    onTap: () {
                                      Navigator.pop(context);
                                      _startEdit(comment);
                                    },
                                  ),
                                if (canDelete)
                                  _ActionRow(
                                    title: isMyComment
                                        ? 'Xóa bình luận'
                                        : 'Xóa bình luận của người này',
                                    icon: Icons.delete_outline,
                                    danger: true,
                                    showDivider: false,
                                    onTap: () {
                                      Navigator.pop(context);
                                      _deleteComment(comment);
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1).animate(animation),
            child: child,
          ),
        );
      },
    );
  }

  Future<void> _sendComment() async {
    final token = await SecureStorageService.getValidToken();
    if (token == null) return;

    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final controller = context.read<CommentController>();

    if (editingComment != null) {
      await controller.editComment(
        token: token,
        commentId: editingComment!.id,
        content: text,
      );
    } else {
      String? parentComment;
      String? replyToComment;
      String? replyToUser;

      if (replyingComment != null) {
        parentComment = replyingComment!.parentComment ?? replyingComment!.id;
        replyToComment = replyingComment!.id;
        replyToUser = replyingComment!.user.id;
      }

      await controller.createComment(
        token: token,
        postId: widget.postId,
        content: text,
        parentComment: parentComment,
        replyToComment: replyToComment,
        replyToUser: replyToUser,
      );
      if (parentComment == null) {
        widget.onCommentCountChanged?.call(1);
      }
    }

    _textController.clear();

    setState(() {
      replyingComment = null;
      editingComment = null;
    });
  }

  void _showUndoDeleteOverlay(
    CommentModel comment,
    VoidCallback onFinalDelete,
  ) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    Timer? timer;

    int remainingSeconds = 5;
    bool isRemoved = false;

    void removeOverlay() {
      if (isRemoved) return;

      isRemoved = true;
      timer?.cancel();

      if (entry.mounted) {
        entry.remove();
      }
    }

    entry = OverlayEntry(
      builder: (_) {
        return Positioned(
          left: 16,
          right: 16,
          bottom: 92,
          child: Material(
            color: const Color(0xFF2B2B2B),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Đã xóa bình luận · Hoàn tác trong ${remainingSeconds}s',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      removeOverlay();

                      final undoToken =
                          await SecureStorageService.getValidToken();
                      if (undoToken == null || !mounted) return;

                      await context.read<CommentController>().undoDeleteComment(
                        token: undoToken,
                        commentId: comment.id,
                      );
                    },
                    child: const Text('Hoàn tác'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(entry);

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isRemoved) {
        timer.cancel();
        return;
      }

      remainingSeconds--;

      if (remainingSeconds <= 0) {
        removeOverlay();
        onFinalDelete();
        return;
      }

      if (entry.mounted) {
        entry.markNeedsBuild();
      }
    });
  }

  Future<void> _deleteComment(CommentModel comment) async {
    final token = await SecureStorageService.getValidToken();
    if (token == null) return;

    await context.read<CommentController>().deleteComment(
      token: token,
      commentId: comment.id,
    );
    if (!mounted) return;
    bool didUndo = false;
    _showUndoDeleteOverlay(comment, () {
      widget.onCommentCountChanged?.call(-1);
    });
  }

  void _startReply(CommentModel comment) {
    setState(() {
      replyingComment = comment;
      editingComment = null;
    });

    _textController.text = '@${comment.user.username} ';
    _textController.selection = TextSelection.fromPosition(
      TextPosition(offset: _textController.text.length),
    );

    FocusScope.of(context).requestFocus(_focusNode);
  }

  void _startEdit(CommentModel comment) {
    setState(() {
      editingComment = comment;
      replyingComment = null;
      _textController.text = comment.content;
    });

    _textController.selection = TextSelection.fromPosition(
      TextPosition(offset: _textController.text.length),
    );

    FocusScope.of(context).requestFocus(_focusNode);
  }

  void _cancelInputMode() {
    setState(() {
      replyingComment = null;
      editingComment = null;
      _textController.clear();
    });
  }

  Future<void> _toggleAllowComments(bool value) async {
    if (isUpdatingAllowComments) return;

    setState(() {
      isUpdatingAllowComments = true;
    });

    try {
      final token = await SecureStorageService.getValidToken();

      if (token == null) return;

      final result = await context
          .read<CommentController>()
          .toggleAllowComments(
            token: token,
            postId: widget.postId,
            allowComments: value,
          );

      if (!mounted) return;

      setState(() {
        allowComments = result;
        if (!result) {
          replyingComment = null;
          editingComment = null;
          _textController.clear();
          FocusScope.of(context).unfocus();
        }
      });
    } catch (e) {
      debugPrint('toggle allow comments error: $e');
    } finally {
      if (mounted) {
        setState(() {
          isUpdatingAllowComments = false;
        });
      }
    }
  }

  void _showCommentManageSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      barrierColor: Colors.black.withOpacity(0.35),
      isDismissible: true,
      enableDrag: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'Quản lý bình luận',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 22),

                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        allowComments
                            ? Icons.chat_bubble_outline
                            : Icons.comments_disabled_outlined,
                      ),
                      title: Text(
                        allowComments
                            ? 'Đang cho phép bình luận'
                            : 'Đã tắt bình luận',
                      ),
                      subtitle: Text(
                        allowComments
                            ? 'Mọi người có thể bình luận bài viết này'
                            : 'Không ai có thể bình luận bài viết này',
                      ),
                      trailing: Switch(
                        value: allowComments,
                        onChanged: isUpdatingAllowComments
                            ? null
                            : (value) async {
                                await _toggleAllowComments(value);
                                setModalState(() {});
                              },
                      ),
                    ),

                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.filter_alt_outlined),
                      title: const Text('Lọc từ khóa'),
                      subtitle: const Text(
                        'Ẩn bình luận chứa từ khóa nhạy cảm',
                      ),
                      onTap: () {},
                    ),

                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.done_all_outlined),
                      title: const Text('Chọn nhiều bình luận'),
                      subtitle: const Text(
                        'Xóa hoặc ẩn nhiều bình luận cùng lúc',
                      ),
                      onTap: () {},
                    ),

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: SizedBox(
                    height: 44,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Center(
                          child: Text(
                            'Bình luận',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),

                        Positioned(
                          right: 0,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.sort_rounded, size: 22),
                                initialValue: selectedSort,
                                onSelected: (value) async {
                                  setState(() {
                                    selectedSort = value;
                                  });

                                  final token =
                                      await SecureStorageService.getValidToken();

                                  if (token == null) return;
                                  if (!mounted) return;

                                  context
                                      .read<CommentController>()
                                      .loadComments(
                                        token: token,
                                        postId: widget.postId,
                                        refresh: true,
                                        sort: value,
                                      );
                                },
                                itemBuilder: (context) => const [
                                  PopupMenuItem(
                                    value: 'newest',
                                    child: Text('Mới nhất'),
                                  ),
                                  PopupMenuItem(
                                    value: 'oldest',
                                    child: Text('Cũ nhất'),
                                  ),
                                  PopupMenuItem(
                                    value: 'top',
                                    child: Text('Nổi bật'),
                                  ),
                                ],
                              ),

                              if (widget.currentUserId == widget.postOwnerId)
                                IconButton(
                                  onPressed: _showCommentManageSheet,
                                  icon: const Icon(
                                    Icons.more_horiz_rounded,
                                    size: 24,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Divider(height: 24),
              Expanded(
                child: Consumer<CommentController>(
                  builder: (context, controller, _) {
                    if (controller.isLoading && controller.comments.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (controller.comments.isEmpty) {
                      return const Center(
                        child: Text(
                          'Chưa có bình luận nào',
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: scrollController,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: controller.comments.length,
                      itemBuilder: (context, index) {
                        final comment = controller.comments[index];

                        return CommentItem(
                          comment: comment,
                          onReplyComment: allowComments
                              ? (selectedComment) {
                                  _startReply(selectedComment);
                                }
                              : null,
                          onEdit: () => _startEdit(comment),
                          onDelete: () => _deleteComment(comment),
                          onLongPressComment: (selectedComment) {
                            _showCommentActions(selectedComment);
                          },
                          onViewReplies: (selectedComment) async {
                            final token =
                                await SecureStorageService.getValidToken();
                            if (token == null) return;
                            if (!mounted) return;

                            context.read<CommentController>().loadReplies(
                              token: token,
                              parentCommentId: selectedComment.id,
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              if (replyingComment != null || editingComment != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  color: Colors.grey.shade100,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          editingComment != null
                              ? 'Đang sửa bình luận'
                              : 'Đang trả lời @${replyingComment!.user.username}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _cancelInputMode,
                        child: const Icon(Icons.close, size: 18),
                      ),
                    ],
                  ),
                ),
              if (allowComments)
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 12,
                      right: 12,
                      top: 8,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _textController,
                            focusNode: _focusNode,
                            minLines: 1,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: editingComment != null
                                  ? 'Sửa bình luận...'
                                  : replyingComment != null
                                  ? 'Trả lời bình luận...'
                                  : 'Thêm bình luận...',
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(22),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Consumer<CommentController>(
                          builder: (context, controller, _) {
                            return IconButton(
                              onPressed: controller.isSending
                                  ? null
                                  : _sendComment,
                              icon: controller.isSending
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.send_rounded,
                                      color: Colors.black,
                                    ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                )
              else
                SafeArea(
                  top: false,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.comments_disabled_outlined,
                          size: 18,
                          color: Colors.grey.shade700,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Chủ bài viết đã tắt bình luận',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
