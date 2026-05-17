import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../../core/storage/secure_storage_service.dart';
import '../../../post/presentation/widgets/post_card.dart';
import '../controllers/profile_controller.dart';

class UserPostsScreen extends StatefulWidget {
  final String userId;
  final int initialIndex;

  const UserPostsScreen({
    super.key,
    required this.userId,
    required this.initialIndex,
  });

  @override
  State<UserPostsScreen> createState() => _UserPostsScreenState();
}

class _UserPostsScreenState extends State<UserPostsScreen> {
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  bool _didInitialScroll = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final token = await SecureStorageService.getValidToken();
      if (token == null || !mounted) return;

      await context.read<ProfileController>().loadUserPostFeed(
        token: token,
        userId: widget.userId,
        refresh: true,
      );

      _scrollToInitialPost();
    });

    _itemPositionsListener.itemPositions.addListener(_handleScroll);
  }

  void _scrollToInitialPost() {
    if (_didInitialScroll) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_itemScrollController.isAttached) return;

      _didInitialScroll = true;

      _itemScrollController.scrollTo(
        index: widget.initialIndex,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    });
  }

  Future<void> _handleScroll() async {
    final positions = _itemPositionsListener.itemPositions.value;
    if (positions.isEmpty) return;

    final maxIndex = positions
        .where((item) => item.itemTrailingEdge > 0)
        .map((item) => item.index)
        .reduce((a, b) => a > b ? a : b);

    final controller = context.read<ProfileController>();
    final posts = controller.userFeedPosts;

    if (maxIndex >= posts.length - 3) {
      final token = await SecureStorageService.getValidToken();
      if (token == null || !mounted) return;

      await controller.loadMoreUserPostFeed(
        token: token,
        userId: widget.userId,
      );
    }
  }

  @override
  void dispose() {
    _itemPositionsListener.itemPositions.removeListener(_handleScroll);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileController>(
      builder: (context, controller, child) {
        final posts = controller.userFeedPosts;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.5,
            foregroundColor: Colors.black,
            title: const Text(
              'Bài viết',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          body: controller.isLoadingUserFeed && posts.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ScrollablePositionedList.builder(
                  itemScrollController: _itemScrollController,
                  itemPositionsListener: _itemPositionsListener,
                  itemCount:
                      posts.length + (controller.isLoadingMoreUserFeed ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= posts.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 18),
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    }

                    return PostCard(post: posts[index]);
                  },
                ),
        );
      },
    );
  }
}
