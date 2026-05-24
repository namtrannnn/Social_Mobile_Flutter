import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/storage/secure_storage_service.dart';

import '../controllers/post_controller.dart';
import '../controllers/comment_controller.dart';
import '../widgets/post_card.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(_loadData);
  }

  Future<void> _loadData() async {
    final token = await SecureStorageService.getValidToken();

    if (token == null) return;
    if (!mounted) return;

    await context.read<PostController>().loadPostDetail(
      token: token,
      postId: widget.postId,
    );

    if (!mounted) return;

    await context.read<CommentController>().loadComments(
      token: token,
      postId: widget.postId,
      refresh: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final postController = context.watch<PostController>();

    final post = postController.selectedPost;
    final isLoading = postController.isLoadingDetail;
    final error = postController.detailError;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Bài viết',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.4,
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: Builder(
          builder: (context) {
            if (isLoading && post == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (post == null) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 180),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Center(
                      child: Text(
                        error ?? 'Không tải được bài viết',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [PostCard(post: post)],
            );
          },
        ),
      ),
    );
  }
}
