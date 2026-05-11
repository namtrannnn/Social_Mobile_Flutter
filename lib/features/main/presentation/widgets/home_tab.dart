import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../post/presentation/controllers/post_controller.dart';
import '../../../story/presentation/widgets/story_section.dart';
import '../../../post/presentation/widgets/post_card.dart';
import '../../../post/presentation/widgets/pending_post_card.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../app/routes/route_names.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final token = await SecureStorageService.getValidToken();

      if (token == null) return;

      context.read<PostController>().loadFeedPosts(token);
    });

    _scrollController.addListener(() async {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 300) {
        final token = await SecureStorageService.getValidToken();

        if (token == null) return;

        context.read<PostController>().loadMoreFeedPosts(token);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildInstagramHeader() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      color: Colors.white,
      child: Row(
        children: [
          const Text(
            'Instagram',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              fontFamily: 'Billabong',
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, RouteNames.createPost);
            },
            icon: const Icon(Icons.add_box_outlined, size: 28),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.favorite_border, size: 28),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.send_outlined, size: 28),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final postController = context.watch<PostController>();

    return SafeArea(
      child: Column(
        children: [
          _buildInstagramHeader(),

          Expanded(
            child: postController.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.zero,
                    itemCount:
                        1 +
                        postController.pendingPosts.length +
                        postController.posts.length +
                        (postController.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      // STORY
                      if (index == 0) {
                        return const StorySection();
                      }

                      final pendingIndex = index - 1;

                      // PENDING POSTS
                      if (pendingIndex < postController.pendingPosts.length) {
                        final pendingPost =
                            postController.pendingPosts[pendingIndex];

                        return PendingPostCard(
                          pendingPost: pendingPost,
                          onDelete: () {
                            postController.removePendingPost(
                              pendingPost.tempId,
                            );
                          },
                          onRetry: () async {
                            final token =
                                await SecureStorageService.getValidToken();
                            if (token == null) return;

                            postController.retryPendingPost(
                              token: token,
                              pendingPost: pendingPost,
                            );
                          },
                        );
                      }

                      final postIndex =
                          pendingIndex - postController.pendingPosts.length;

                      // LOADING MORE
                      if (postController.isLoadingMore &&
                          postIndex == postController.posts.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final post = postController.posts[postIndex];

                      return PostCard(post: post);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
