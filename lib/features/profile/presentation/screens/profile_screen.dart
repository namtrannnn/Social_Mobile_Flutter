import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/storage/secure_storage_service.dart';

import '../controllers/profile_controller.dart';
import '../widgets/profile_action_buttons.dart';
import '../widgets/profile_app_bar.dart';
import '../widgets/profile_bio_section.dart';
import '../widgets/profile_post_grid.dart';
import '../widgets/profile_tab_section.dart';
import '../widgets/profile_top_section.dart';
import '../widgets/profile_friends_section.dart';
import '../../../post/presentation/screens/post_detail_screen.dart';
import '../../../friend/presentation/controllers/friend_controller.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId;

  const ProfileScreen({super.key, this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ScrollController _scrollController = ScrollController();

  bool get isMyProfile => widget.userId == null;

  void _scrollToGridPosts() {
    _scrollController.animateTo(
      260,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  }

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final token = await SecureStorageService.getValidToken();
      if (token == null) return;

      if (!mounted) return;

      final controller = context.read<ProfileController>();

      if (isMyProfile) {
        controller.clearMyProfile();
        await controller.loadMyProfile(token);
      } else {
        controller.clearViewedProfile();

        await controller.loadUserProfile(token: token, userId: widget.userId!);

        if (!mounted) return;

        await context.read<FriendController>().loadRelationStatus(
          widget.userId!,
        );
      }
    });
  }

  @override
  void didUpdateWidget(covariant ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.userId != widget.userId) {
      Future.microtask(() async {
        final token = await SecureStorageService.getValidToken();
        if (token == null) return;

        if (!mounted) return;

        final controller = context.read<ProfileController>();

        if (isMyProfile) {
          controller.clearMyProfile();
          await controller.loadMyProfile(token);
        } else {
          controller.clearViewedProfile();

          await controller.loadUserProfile(
            token: token,
            userId: widget.userId!,
          );

          if (!mounted) return;

          await context.read<FriendController>().loadRelationStatus(
            widget.userId!,
          );
        }
      });
    }
  }

  Future<void> _refreshProfile(ProfileController controller) async {
    final token = await SecureStorageService.getValidToken();
    if (token == null) return;

    if (isMyProfile) {
      await controller.loadMyProfile(token);
    } else {
      await controller.loadUserProfile(token: token, userId: widget.userId!);

      if (!mounted) return;

      await context.read<FriendController>().loadRelationStatus(widget.userId!);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileController>(
      builder: (context, controller, child) {
        final profile = isMyProfile
            ? controller.myProfile
            : controller.viewedProfile;

        final gridPosts = isMyProfile
            ? controller.myGridPosts
            : controller.viewedGridPosts;
        final mentionedPosts = isMyProfile
            ? controller.myMentionedPosts
            : controller.viewedMentionedPosts;
        if (controller.isLoadingProfile && profile == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (profile == null) {
          return const Scaffold(
            body: Center(child: Text('Không tải được profile')),
          );
        }

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: ProfileAppBar(profile: profile),
            ),
            body: RefreshIndicator(
              triggerMode: RefreshIndicatorTriggerMode.onEdge,
              notificationPredicate: (_) => true,
              color: Colors.black,
              backgroundColor: Colors.white,
              onRefresh: () => _refreshProfile(controller),
              child: NestedScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ProfileTopSection(
                            profile: profile,
                            onPostsTap: _scrollToGridPosts,
                          ),
                          ProfileBioSection(profile: profile),
                          ProfileActionButtons(profile: profile),
                          ProfileFriendsSection(profile: profile),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                    const SliverPersistentHeader(
                      pinned: true,
                      delegate: ProfileTabSection(),
                    ),
                  ];
                },
                body: TabBarView(
                  children: [
                    ProfilePostGrid(userId: profile.user.id, posts: gridPosts),

                    const Center(child: Text('Chưa có reels')),

                    controller.isLoadingMentioned && mentionedPosts.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : mentionedPosts.isEmpty
                        ? const Center(
                            child: Text(
                              'Chưa có bài viết nhắc tới người này',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ProfilePostGrid(
                            userId: profile.user.id,
                            posts: mentionedPosts,
                            openAsDetail: true,
                          ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
